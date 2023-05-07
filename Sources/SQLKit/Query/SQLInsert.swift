/// `INSERT INTO ...` statement.
///
/// See ``SQLInsertBuilder``.
public struct SQLInsert: SQLExpression {
    public var table: any SQLExpression
    
    /// Array of column identifiers to insert values for.
    public var columns: [any SQLExpression]
    
    /// Two-dimensional array of values to insert. The count of each nested array _must_
    /// be equal to the count of `columns`.
    ///
    /// Use the `DEFAULT` literal to omit a value and that is specified as a column.
    public var values: [[any SQLExpression]]

    /// A unique key conflict resolution strategy.
    public var conflictStrategy: SQLConflictResolutionStrategy?

    /// Optionally append a `RETURNING` clause that, where supported, returns the supplied supplied columns.
    public var returning: SQLReturning?
    
    /// Creates a new `SQLInsert`.
    @inlinable
    public init(table: any SQLExpression) {
        self.table = table
        self.columns = []
        self.values = []
        self.conflictStrategy = nil
        self.returning = nil
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        let modifier = self.conflictStrategy?.queryModifier(for: serializer)
        
        serializer.statement {
            $0.append("INSERT")
            if let modifier = modifier {
                $0.append(modifier)
            }
            $0.append("INTO", self.table)
            $0.append(SQLGroupExpression(self.columns))
            $0.append("VALUES", SQLList(self.values.map(SQLGroupExpression.init)))
            if let conflictStrategy = self.conflictStrategy, modifier == nil {
                $0.append(conflictStrategy)
            }
            if let returning = self.returning {
                $0.append(returning)
            }
        }
    }
}
