/// An escaped identifier, i.e., `"name"`.
public protocol SQLIdentifier: SQLSerializable, ExpressibleByStringLiteral {
    /// Creates a new `SQLIdentifier`.
    static func identifier(_ string: String) -> Self
    
    /// String value.
    var string: String { get set }
}

// MARK: Convenience

extension SQLIdentifier {
    /// Creates a new `SQLIdentifier` from a key path. Uses the property's name.
    ///
    ///     .keyPath(\Planet.name)
    ///
    /// This method will result in a `fatalError` if the property cannot be reflected.
    public static func keyPath<T,V>(_ keyPath: KeyPath<T, V>) -> Self where T: SQLTable {
        do {
            guard let property = try T.reflectProperty(forKey: keyPath) else {
                fatalError("Could not reflect property of type '\(V.self)' on '\(T.self)': \(keyPath)")
            }
            return .identifier(property.path[0])
        } catch {
            fatalError("Could not reflect property of type '\(V.self)' on '\(T.self)': \(error)")
        }
    }
}

// MARK: Generic

/// Generic implementation of `SQLIdentifier`.
public struct GenericSQLIdentifier: SQLIdentifier {
    /// See `SQLIdentifier`.
    public static func identifier(_ string: String) -> GenericSQLIdentifier {
        return self.init(string)
    }
    
    /// See `SQLIdentifier`.
    public var string: String
    
    /// Creates a new `SQLIdentifier`.
    public init(_ value: String) {
        self.string = value
    }
    
    /// See `ExpressibleByStringLiteral`.
    public init(stringLiteral value: String) {
        self.string = value
    }
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        return "\"" + string + "\""
    }
}
