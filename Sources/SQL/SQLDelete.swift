public protocol SQLDelete: SQLSerializable {
    associatedtype TableIdentifier: SQLTableIdentifier
    associatedtype Expression: SQLExpression
    
    static func delete(_ table: TableIdentifier) -> Self
    
    var table: TableIdentifier { get set }
    
    /// If the WHERE clause is not present, all records in the table are deleted. If a WHERE clause is supplied,
    /// then only those rows for which the WHERE clause boolean expression is true are deleted. Rows for which
    /// the expression is false or NULL are retained.
    var predicate: Expression? { get set }
}

// MARK: Generic

public struct GenericSQLDelete<TableIdentifier, Expression>: SQLDelete
    where TableIdentifier: SQLTableIdentifier, Expression: SQLExpression
{
    /// See `SQLDelete`.
    public static func delete(_ table: TableIdentifier) -> GenericSQLDelete<TableIdentifier, Expression> {
        return .init(table: table, predicate: nil)
    }
    
    /// See `SQLDelete`.
    public var table: TableIdentifier
    
    /// See `SQLDelete`.
    public var predicate: Expression?
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append("DELETE FROM")
        sql.append(table.serialize(&binds))
        if let predicate = self.predicate {
            sql.append("WHERE")
            sql.append(predicate.serialize(&binds))
        }
        return sql.joined(separator: " ")
    }
}
