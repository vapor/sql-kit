/// Identifies a table in a SQL database.
#warning("consider need for separate protocol")
public protocol SQLTableIdentifier: SQLSerializable, ExpressibleByStringLiteral {
    /// See `SQLIdentifier`.
    associatedtype Identifier: SQLIdentifier
    
    /// Creates a new `SQLTableIdentifier`.
    static func table(_ identifier: Identifier) -> Self
    
    /// Table identifier.
    var identifier: Identifier { get set }
}

// MARK: Convenience
//
//extension SQLTableIdentifier {
//    /// Creates a `SQLTableIdentifier` from a `SQLTable`.
//    public static func table<Table>(_ table: Table.Type) -> Self
//        where Table: SQLTable
//    {
//        return .table(.identifier(Table.sqlTableIdentifierString))
//    }
//    
//    /// Creates a `SQLTableIdentifier` from a `Decodable` type.
//    /// If the type doesn't conform to `SQLTable`, then `nil` is returned.
//    public static func table<T>(any: T.Type) -> Self? {
//        guard let table = any as? AnySQLTable.Type else {
//            return nil
//        }
//        return .table(.identifier(table.sqlTableIdentifierString))
//    }
//}

//extension SQLTableIdentifier {
//    /// Creates a `SQLTableIdentifier` from a `SQLTable` key path.
//    public static func keyPath<T,V>(_ keyPath: KeyPath<T, V>) -> Self where T: SQLTable {
//        return .table(.identifier(T.sqlTableIdentifierString))
//    }
//}
//
//// MARK: Generic
//
///// Generic implementation of `SQLTableIdentifier`.
//public struct GenericSQLTableIdentifier<Identifier>: SQLTableIdentifier, ExpressibleByStringLiteral
//    where Identifier: SQLIdentifier
//{
//    /// See `SQLTableIdentifier`.
//    public static func table(_ identifier: Identifier) -> GenericSQLTableIdentifier<Identifier> {
//        return .init(identifier)
//    }
//
//    /// See `SQLTableIdentifier`.
//    public var identifier: Identifier
//
//    /// Creates a new `GenericSQLTableIdentifier`.
//    public init(_ identifier: Identifier) {
//        self.identifier = identifier
//    }
//
//    /// See `ExpressibleByStringLiteral`.
//    public init(stringLiteral value: String) {
//        self.identifier = .identifier(value)
//    }
//
//    /// See `SQLSerializable`.
//    public func serialize(_ binds: inout [Encodable]) -> String {
//        return identifier.serialize(&binds)
//    }
//}
