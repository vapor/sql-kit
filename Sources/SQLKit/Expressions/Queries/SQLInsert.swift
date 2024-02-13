/// `INSERT INTO ...` statement.
///
/// See ``SQLInsertBuilder``.
public struct SQLInsert: SQLExpression {
    /// The destination table.
    public var table: any SQLExpression
    
    /// Array of column identifiers to insert values for.
    public var columns: [any SQLExpression] = []
    
    /// Two-dimensional array of values to insert. The count of each nested array _must_
    /// be equal to the count of ``columns``.
    ///
    /// Use the `DEFAULT` literal to omit a value and that is specified as a column.
    ///
    /// If both ``values`` and ``valueQuery`` are specified, the only ``values`` is used.
    public var values: [[any SQLExpression]] = []
    
    /// An ``SQLSubquery`` specifying a `SELECT` statement used to generate values to insert.
    ///
    /// If both ``values`` and ``valueQuery`` are specified, the only ``values`` is used.
    public var valueQuery: (any SQLExpression)? = nil

    /// A unique key conflict resolution strategy.
    public var conflictStrategy: SQLConflictResolutionStrategy? = nil

    /// Optionally append a `RETURNING` clause that, where supported, returns the supplied supplied columns.
    public var returning: SQLReturning? = nil
    
    /// Creates a new ``SQLInsert``.
    @inlinable
    public init(table: any SQLExpression) {
        self.table = table
    }
    
    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("INSERT")
            $0.append(self.conflictStrategy?.queryModifier(for: $0))
            $0.append("INTO", self.table)
            $0.append(SQLGroupExpression(self.columns))
            if !self.values.isEmpty {
                $0.append("VALUES", SQLList(self.values.map(SQLGroupExpression.init)))
            } else if let subquery = self.valueQuery {
                $0.append(subquery)
            }
            $0.append(self.conflictStrategy)
            $0.append(self.returning)
        }
    }
}
