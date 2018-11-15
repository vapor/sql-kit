/// `DROP TABLE` query.
///
/// See `SQLDropTableBuilder`.
public protocol SQLDropTable: SQLSerializable {
    /// See `SQLTableIdentifier`.
    associatedtype Identifier: SQLIdentifier
    
    /// Creates a new `SQLDropTable`.
    static func dropTable(name table: Identifier) -> Self
    
    /// Table to drop.
    var table: Identifier { get set }
    
    /// The optional `IF EXISTS` clause suppresses the error that would normally
    /// result if the table does not exist.
    var ifExists: Bool { get set }
}

///// Generic implementation of `SQLDropTable`.
//public struct GenericSQLDropTable<TableIdentifier>: SQLDropTable
//    where TableIdentifier: SQLTableIdentifier
//{
//    /// See `SQLDropTable`.
//    public static func dropTable(_ table: TableIdentifier) -> GenericSQLDropTable<TableIdentifier> {
//        return .init(table: table, ifExists: false)
//    }
// 
//    /// See `SQLDropTable`.
//    public var table: TableIdentifier
//    
//    /// See `SQLDropTable`.
//    public var ifExists: Bool
//
//    /// See `SQLSerializable`.
//    public func serialize(_ binds: inout [Encodable]) -> String {
//        var sql: [String] = []
//        sql.append("DROP TABLE")
//        if ifExists {
//            sql.append("IF EXISTS")
//        }
//        sql.append(table.serialize(&binds))
//        return sql.joined(separator: " ")
//    }
//}
