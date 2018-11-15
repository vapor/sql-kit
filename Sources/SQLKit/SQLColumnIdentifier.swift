/// Identifies a column in a particular table.
public protocol SQLColumnIdentifier: SQLSerializable, ExpressibleByStringLiteral {
    /// See `SQLIdentifier`.
    associatedtype Identifier: SQLIdentifier
    
    /// Creates a new `SQLColumnIdentifier`.
    static func column(name: Identifier, table: Identifier?) -> Self
    
    /// Optional identifier for the table this column belongs to.
    var table: Identifier? { get set }
    
    /// Column identifier.
    var name: Identifier { get set }
}

// MARK: Convenience

extension SQLColumnIdentifier {
//    /// Creates a `SQLColumnIdentifier` from a key path into a `SQLTable` type.
//    ///
//    ///     .keyPath(\Planet.name)
//    ///
//    /// This method will result in a `fatalError` if the property cannot be reflected.
//    public static func keyPath<T,V>(_ keyPath: KeyPath<T, V>) -> Self where T: SQLTable {
//        do {
//            guard let property = try T.reflectProperty(forKey: keyPath) else {
//                fatalError("Could not reflect property of type '\(V.self)' on '\(T.self)': \(keyPath)")
//            }
//            return .column(.table(.identifier(T.sqlTableIdentifierString)), .identifier(property.path[0]))
//        } catch {
//            fatalError("Could not reflect property of type '\(V.self)' on '\(T.self)': \(error)")
//        }
//    }
}

// // MARK: Generic

///// Generic implementation of `SQLColumnIdentifier`.
//public struct GenericSQLColumnIdentifier<TableIdentifier, Identifier>: SQLColumnIdentifier, Hashable
//    where TableIdentifier: SQLTableIdentifier, Identifier: SQLIdentifier
//{
//    /// See `SQLColumnIdentifier`.
//    public static func column(_ table: TableIdentifier?, _ identifier: Identifier) -> GenericSQLColumnIdentifier<TableIdentifier, Identifier> {
//        return self.init(table: table, identifier: identifier)
//    }
//
//    /// See `Equatable`.
//    public static func == (lhs: GenericSQLColumnIdentifier<TableIdentifier, Identifier>, rhs: GenericSQLColumnIdentifier<TableIdentifier, Identifier>) -> Bool {
//        return lhs.table?.identifier.string == rhs.table?.identifier.string && lhs.identifier.string == rhs.identifier.string
//    }
//
//    /// See `Hashable`.
//    public var hashValue: Int {
//        if let table = table {
//            return table.identifier.string.hashValue &+ identifier.string.hashValue
//        } else {
//            return identifier.string.hashValue
//        }
//    }
//
//    /// See `SQLColumnIdentifier`.
//    public var table: TableIdentifier?
//
//    /// See `SQLColumnIdentifier`.
//    public var identifier: Identifier
//
//    /// See `SQLSerializable`.
//    public func serialize(_ binds: inout [Encodable]) -> String {
//        switch table {
//        case .some(let table): return table.serialize(&binds) + "." + identifier.serialize(&binds)
//        case .none: return identifier.serialize(&binds)
//        }
//    }
//}
