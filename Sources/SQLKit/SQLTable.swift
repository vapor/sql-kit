/// A type corresponding to a table / view in a SQL database.
//public protocol SQLTable: Codable { }
//
//extension SQLTable {
//    public static func column<C>(_ name: String) -> C
//        where C: SQLColumnIdentifier
//    {
//        return .column(name: .identifier(name), table: self.table())
//    }
//    
//    public static func table<T>() -> T
//        where T: SQLIdentifier
//    {
//        return .identifier(self.sqlTableIdentifierString)
//    }
//}
//
//extension SQLTable {
//    /// See `AnySQLTable`.
//    public static var sqlTableIdentifierString: String {
//        return "\(Self.self)"
//    }
//}
