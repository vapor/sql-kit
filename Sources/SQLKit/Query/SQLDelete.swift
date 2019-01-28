/// `DELETE ... FROM` query.
///
/// See `SQLDeleteBuilder`.
public struct SQLDelete: SQLExpression {
    /// Identifier of table to delete from.
    public var table: SQLIdentifier
    
    /// If the `WHERE` clause is not present, all records in the table are deleted. If a WHERE clause is supplied,
    /// then only those rows for which the WHERE clause boolean expression is true are deleted. Rows for which
    /// the expression is false or NULL are retained.
    public var predicate: SQLExpression?
    
    /// Creates a new `SQLDelete`.
    public init(table: SQLIdentifier) {
        self.table = table
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write("DELETE FROM ")
        self.table.serialize(to: &serializer)
        if let predicate = self.predicate {
            serializer.write(" WHERE ")
            predicate.serialize(to: &serializer)
        }
    }
}
