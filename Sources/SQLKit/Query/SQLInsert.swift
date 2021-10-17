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

    /// A conflict resolution strategy describing how to handle unique key violations. Defaults to
    /// returning a query error.
    public var conflictStrategy: SQLConflictResolutionStrategy

    /// Optionally append a `RETURNING` clause that, where supported, returns the supplied supplied columns.
    public var returning: SQLReturning?
    
    /// Creates a new `SQLInsert`.
    public init(table: SQLExpression) {
        self.table = table
        self.columns = []
        self.values = []
        self.conflictStrategy = .init(targets: Array<String>(), action: .default)
        self.returning = nil
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("INSERT", self.conflictStrategy.queryModifier)
            $0.append("INTO", self.table)
            $0.append(SQLGroupExpression(self.columns))
            $0.append("VALUES", SQLList(self.values.map(SQLGroupExpression.init)))
            $0.append(self.conflictStrategy)
            if let returning = self.returning {
                $0.append(returning)
            }
        }
    }
}
