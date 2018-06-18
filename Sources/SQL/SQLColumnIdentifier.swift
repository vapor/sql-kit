public protocol SQLColumnIdentifier: SQLSerializable {
    associatedtype TableIdentifier: SQLTableIdentifier
    associatedtype Identifier: SQLIdentifier
    
    static func column(_ table: TableIdentifier?, _ identifier: Identifier) -> Self
    
    var table: TableIdentifier? { get set }
    var identifier: Identifier { get set }
}

// MARK: Convenience


extension SQLColumnIdentifier {
    public static func keyPath<T,V>(_ keyPath: KeyPath<T, V>) -> Self where T: SQLTable {
        guard let property = try! T.reflectProperty(forKey: keyPath) else {
            fatalError("Could not reflect property of type \(V.self) on \(T.self): \(keyPath)")
        }
        return .column(.table(.identifier(T.sqlTableIdentifierString)), .identifier(property.path[0]))
    }
}
extension SQLTableIdentifier {
    public static func keyPath<T,V>(_ keyPath: KeyPath<T, V>) -> Self where T: SQLTable {
        return .table(.identifier(T.sqlTableIdentifierString))
    }
}

extension SQLIdentifier {
    public static func keyPath<T,V>(_ keyPath: KeyPath<T, V>) -> Self where T: SQLTable {
        guard let property = try! T.reflectProperty(forKey: keyPath) else {
            fatalError("Could not reflect property of type \(V.self) on \(T.self): \(keyPath)")
        }
        return .identifier(property.path[0])
    }
}

// MARK: Generic

public struct GenericSQLColumnIdentifier<TableIdentifier, Identifier>: SQLColumnIdentifier
    where TableIdentifier: SQLTableIdentifier, Identifier: SQLIdentifier
{
    /// See `SQLColumnIdentifier`.
    public static func column(_ table: TableIdentifier?, _ identifier: Identifier) -> GenericSQLColumnIdentifier<TableIdentifier, Identifier> {
        return self.init(table: table, identifier: identifier)
    }
    
    /// See `SQLColumnIdentifier`.
    public var table: TableIdentifier?
    
    /// See `SQLColumnIdentifier`.
    public var identifier: Identifier
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch table {
        case .some(let table): return table.serialize(&binds) + "." + identifier.serialize(&binds)
        case .none: return identifier.serialize(&binds)
        }
    }
}
