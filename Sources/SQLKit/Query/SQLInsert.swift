/// `INSERT INTO ...` statement.
///
/// See `SQLInsertBuilder`.
public struct SQLInsert: SQLExpression {
    public var table: SQLExpression
    
    /// Array of column identifiers to insert values for.
    public var columns: [SQLExpression]
    
    /// Two-dimensional array of values to insert. The count of each nested array _must_
    /// be equal to the count of `columns`.
    ///
    /// Use the `DEFAULT` literal to omit a value and that is specified as a column.
    public var values: [[SQLExpression]]

    /// A list of unique indexes to which a conflict action, if provided, should apply, creating an upsert.
    ///
    /// - Note: This list is ignored by some databases (such as MySQL), and has no effect at all if `action`
    ///   is set to `.default` or the database does not support conflict handling.
    public var conflictTargets: [SQLExpression]

    /// An action specifying how to handle a conflict between the inserted data and any existing rows, where
    /// a conflict is an attempt to insert one or more rows containing values which violate at least one unique
    /// constraint listed in the `conflictTargets` (or, in some databases, any unique constraint).
    ///
    /// - Important: If the underlying database does not support conflict handling ("upserts"), the value of
    ///   `conflictAction` will be **ignored** and `.default` will be used instead.
    public var conflictAction: SQLConflictAction

    /// Optionally append a `RETURNING` clause that, where supported, returns the supplied supplied columns.
    public var returning: SQLReturning?
    
    /// Creates a new `SQLInsert`.
    public init(table: SQLExpression) {
        self.table = table
        self.columns = []
        self.values = []
        self.conflictTargets = []
        self.conflictAction = .default
        self.returning = nil
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        let upsertSyntax = serializer.dialect.upsertSyntax
        serializer.statement {
            $0.append("INSERT")
            if case .mysqlLike = upsertSyntax, case .noAction = self.conflictAction {
                $0.append("IGNORE")
            }
            $0.append("INTO")
            $0.append(self.table)
            $0.append(SQLGroupExpression(self.columns))
            $0.append("VALUES")
            $0.append(SQLList(self.values.map(SQLGroupExpression.init)))
            if case .standard = upsertSyntax, case .noAction = self.conflictAction {
                $0.append("ON CONFLICT DO NOTHING")
            } else if case .update(let assignments, let predicate) = self.conflictAction {
                $0.append(SQLUpsertUpdate(assignments: assignments, predicate: predicate))
            }
            if let returning = self.returning {
                $0.append(returning)
            }
        }
    }
}

/// Encapsulates the serialization logic for the `.update` case of a `SQLConflictAction`. Not made
/// public because it does not represent a standalone SQL clause/expression and relies upon a
/// containing context (i.e. the upsert query) to have ensured some preconditions.
fileprivate struct SQLUpsertUpdate: SQLExpression {
    var assignments: [SQLExpression]
    var predicate: SQLExpression?
    
    init(assignments: [SQLExpression], predicate: SQLExpression?) {
        assert(!assignments.isEmpty, "An upsert with updates must assign at least one column.")
        
        self.assignments = assignments
        self.predicate = predicate
    }
    
    func serialize(to serializer: inout SQLSerializer) {
        /// Add the "update on conflict" clause. If upserts aren't supported, bail out now.
        switch serializer.dialect.upsertSyntax {
            case .unsupported:
                return
            case .standard:
                serializer.write("ON CONFLICT DO UPDATE SET ")
            case .mysqlLike:
                serializer.write("ON DUPLICATE KEY UPDATE ")
        }
        
        /// Serialize the column assignments.
        SQLList(self.assignments).serialize(to: &serializer)
        
        /// If the upsert syntax supports predicates and one was provided, serialize it.
        if case .standard = serializer.dialect.upsertSyntax, let predicate = self.predicate {
            serializer.write("WHERE ")
            predicate.serialize(to: &serializer)
        }
    }
}
