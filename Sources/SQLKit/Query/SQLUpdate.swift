/// `UPDATE` statement.
///
/// See `SQLUpdateBuilder`.
public struct SQLUpdate: SQLExpression {
    /// Table to update.
    public var table: SQLExpression
    
    /// Zero or more identifier: expression pairs to update.
    public var values: [SQLExpression]
    
    /// Optional predicate to limit updated rows.
    public var predicate: SQLExpression?

    /// Optionally append a `RETURNING` clause that, where supported, returns the supplied supplied columns.
    public var returning: SQLReturning?
    
    /// Creates a new `SQLUpdate`.
    public init(table: SQLExpression) {
        self.table = table
        self.values = []
        self.predicate = nil
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("UPDATE")
            $0.append(self.table)
            $0.append("SET")
            $0.append(SQLList(self.values))
            if let predicate = self.predicate {
                $0.append("WHERE")
                $0.append(predicate)
            }
            if let returning = self.returning {
                $0.append(returning)
            }
        }
    }
}
