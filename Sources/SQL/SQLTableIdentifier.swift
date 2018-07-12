public protocol SQLTableIdentifier: SQLSerializable {
    associatedtype Identifier: SQLIdentifier
    
    static func table(_ identifier: Identifier) -> Self
    var identifier: Identifier { get set }
}

// MARK: Convenience

extension SQLTableIdentifier {
    public static func table<Table>(_ table: Table.Type) -> Self
        where Table: SQLTable
    {
        return .table(.identifier(Table.sqlTableIdentifierString))
    }
}

extension SQLTableIdentifier {
    public static func keyPath<T,V>(_ keyPath: KeyPath<T, V>) -> Self where T: SQLTable {
        return .table(.identifier(T.sqlTableIdentifierString))
    }
}

// MARK: Generic

public struct GenericSQLTableIdentifier<Identifier>: SQLTableIdentifier, ExpressibleByStringLiteral
    where Identifier: SQLIdentifier
{
    /// See `SQLTableIdentifier`.
    public static func table(_ identifier: Identifier) -> GenericSQLTableIdentifier<Identifier> {
        return .init(identifier)
    }
    
    /// See `SQLTableIdentifier`.
    public var identifier: Identifier

    /// Creates a new `GenericSQLTableIdentifier`.
    public init(_ identifier: Identifier) {
        self.identifier = identifier
    }

    /// See `ExpressibleByStringLiteral`.
    public init(stringLiteral value: String) {
        self.identifier = .identifier(value)
    }

    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        return identifier.serialize(&binds)
    }
}
