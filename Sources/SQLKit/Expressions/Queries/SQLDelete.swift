/// An expression representing a `CREATE TRIGGER` query. Used to remove rows from a table.
///
/// ```sql
/// DELETE FROM "table"
///     WHERE "column1"=$0
///     RETURNING "id"
/// ```
///
/// See ``SQLDeleteBuilder``.
public struct SQLDelete: SQLExpression {
    /// An optional common table expression group.
    public var tableExpressionGroup: SQLCommonTableExpressionGroup?
    
    /// The table containing rows to delete.
    public var table: any SQLExpression
    
    /// A predicate specifying which rows to delete.
    ///
    /// If this is `nil`, all records in the table are deleted. When this is the intended behavior, `TRUNCATE` is
    /// usually much faster, but does not play nicely with transactions in some dialects.
    public var predicate: (any SQLExpression)?

    /// An optional ``SQLReturning`` clause specifying data to return from the deleted rows.
    ///
    /// This can be used to perform a "queue pop" operation by both reading and deleting a row, but is not the most
    /// performant way to do so.
    public var returning: SQLReturning?
    
    /// Create a new row deletion query.
    ///
    /// - Parameter table: The table containing the rows to be deleted.
    @inlinable
    public init(table: any SQLExpression) {
        self.table = table
    }
    
    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append(self.tableExpressionGroup)
            
            $0.append("DELETE FROM", self.table)
            if let predicate = self.predicate {
                $0.append("WHERE", predicate)
            }
            $0.append(self.returning)
        }
    }
}
