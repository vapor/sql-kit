/// `DELETE ... FROM` query.
///
/// See `SQLDeleteBuilder`.
public struct SQLDelete: SQLExpression {
    /// Identifier of table to delete from.
    public var table: SQLExpression
    
    /// If the `WHERE` clause is not present, all records in the table are deleted. If a WHERE clause is supplied,
    /// then only those rows for which the WHERE clause boolean expression is true are deleted. Rows for which
    /// the expression is false or NULL are retained.
    public var predicate: SQLExpression?

    /// Optionally append a `RETURNING` clause that, where supported, returns the supplied supplied columns.
    public var returning: SQLReturning?
    
    /// Creates a new `SQLDelete`.
    public init(table: SQLExpression) {
        self.table = table
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("DELETE FROM")
            $0.append(self.table)
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
