/// `DELETE ... FROM` query.
///
/// See ``SQLDeleteBuilder``.
public struct SQLDelete: SQLExpression {
    /// Identifier of table to delete from.
    public var table: any SQLExpression
    
    /// If the `WHERE` clause is not present, all records in the table are deleted. If a WHERE clause is supplied,
    /// then only those rows for which the WHERE clause boolean expression is true are deleted. Rows for which
    /// the expression is false or NULL are retained.
    public var predicate: (any SQLExpression)?

    /// Optionally append a `RETURNING` clause that, where supported, returns the supplied supplied columns.
    public var returning: SQLReturning?
    
    /// Creates a new `SQLDelete`.
    @inlinable
    public init(table: any SQLExpression) {
        self.table = table
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("DELETE FROM", self.table)
            if let predicate = self.predicate {
                $0.append("WHERE", predicate)
            }
            if let returning = self.returning {
                $0.append(returning)
            }
        }
    }
}
