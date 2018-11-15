/// `CREATE INDEX` query.
///
/// See `SQLCreateIndexBuilder`.
public protocol SQLCreateIndex: SQLSerializable {
    /// See `SQLIndexModifier`.
    associatedtype Modifier: SQLIndexModifier
    
    /// See `SQLIdentifier`.
    associatedtype Identifier: SQLIdentifier
    
    /// See `SQLColumnIdentifier`.
    associatedtype ColumnIdentifier: SQLColumnIdentifier
    
    /// Creates a new `SQLCreateIndex.
    static func createIndex(name: Identifier) -> Self
    
    /// Type of index to create, see `SQLIndexModifier`.
    var modifier: Modifier? { get set }
    
    /// Columns to index.
    var columns: [ColumnIdentifier] { get set }
}

///// See `SQLCreateIndex`.
//public struct GenericSQLCreateIndex<Modifier, Identifier, ColumnIdentifier>: SQLCreateIndex where
//    Modifier: SQLIndexModifier, Identifier: SQLIdentifier, ColumnIdentifier: SQLColumnIdentifier
//{
//    /// Convenience alias for self.
//    public typealias `Self` = GenericSQLCreateIndex<Modifier, Identifier, ColumnIdentifier>
//    
//    /// See `SQLCreateIndex`.
//    public static func createIndex(name identifier: Identifier) -> Self {
//        return .init(modifier: nil, identifier: identifier, columns: [])
//    }
//    
//    /// See `SQLCreateIndex`.
//    public var modifier: Modifier?
//    
//    /// See `SQLCreateIndex`.
//    public var identifier: Identifier
//    
//    /// See `SQLCreateIndex`.
//    public var columns: [ColumnIdentifier]
//    
//    /// See `SQLSerializable`.
//    public func serialize(_ binds: inout [Encodable]) -> String {
//        var sql: [String] = []
//        sql.append("CREATE")
//        if let modifier = modifier {
//            sql.append(modifier.serialize(&binds))
//        }
//        sql.append("INDEX")
//        sql.append(identifier.serialize(&binds))
//        if let table = columns.first?.table {
//            sql.append("ON")
//            sql.append(table.serialize(&binds))
//        }
//        sql.append("(" + columns.map { $0.identifier }.serialize(&binds) + ")")
//        return sql.joined(separator: " ")
//    }
//}
