public protocol SQLCreateIndex: SQLSerializable {
    associatedtype Modifier: SQLIndexModifier
    associatedtype Identifier: SQLIdentifier
    associatedtype TableIdentifier: SQLTableIdentifier
    
    static func createIndex(_ identifier: Identifier, _ table: TableIdentifier, _ columns: [Identifier]) -> Self
    
    var modifier: Modifier? { get set }
}

public struct GenericSQLCreateIndex<Modifier, Identifier, TableIdentifier>: SQLCreateIndex where
    Modifier: SQLIndexModifier, Identifier: SQLIdentifier, TableIdentifier: SQLTableIdentifier
{
    public typealias `Self` = GenericSQLCreateIndex<Modifier, Identifier, TableIdentifier>
    
    /// See `SQLCreateIndex`.
    public static func createIndex(_ identifier: Identifier, _ table: TableIdentifier, _ columns: [Identifier]) -> Self {
        return .init(modifier: nil, identifier: identifier, table: table, columns: columns)
    }
    
    /// See `SQLCreateIndex`.
    public var modifier: Modifier?
    
    public var identifier: Identifier
    
    public var table: TableIdentifier
    
    public var columns: [Identifier]
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append("CREATE")
        if let modifier = modifier {
            sql.append(modifier.serialize(&binds))
        }
        sql.append("INDEX")
        sql.append(identifier.serialize(&binds))
        sql.append("ON")
        sql.append(table.serialize(&binds))
        sql.append("(" + columns.serialize(&binds) + ")")
        return sql.joined(separator: " ")
    }
}
