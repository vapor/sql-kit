/// `DELETE ... FROM` query.
///
/// See `SQLDeleteBuilder`.
public protocol SQLDelete: SQLSerializable {
    /// See `SQLTableIdentifier`.
    associatedtype Identifier: SQLIdentifier
    
    /// See `SQLExpression`.
    associatedtype Expression: SQLExpression
    
    /// Creates a new `SQLDelete`.
    static func delete(table: Identifier) -> Self
    
    /// Identifier of table to delete from.
    var table: Identifier { get set }
    
    /// If the `WHERE` clause is not present, all records in the table are deleted. If a WHERE clause is supplied,
    /// then only those rows for which the WHERE clause boolean expression is true are deleted. Rows for which
    /// the expression is false or NULL are retained.
    var predicate: Expression? { get set }
}
