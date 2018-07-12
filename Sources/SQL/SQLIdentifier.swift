public protocol SQLIdentifier: SQLSerializable, ExpressibleByStringLiteral {
    static func identifier(_ string: String) -> Self
    var string: String { get set }
}

// MARK: Convenience

extension SQLIdentifier {
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

public struct GenericSQLIdentifier: SQLIdentifier {
    public static func identifier(_ string: String) -> GenericSQLIdentifier {
        return self.init(string)
    }
    
    public var string: String
    
    public init(_ value: String) {
        self.string = value
    }
    
    public init(stringLiteral value: String) {
        self.string = value
    }
    
    public func serialize(_ binds: inout [Encodable]) -> String {
        return "\"" + string + "\""
    }
}
