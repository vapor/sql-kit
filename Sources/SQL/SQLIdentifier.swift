public protocol SQLIdentifier: SQLSerializable {
    static func identifier(_ string: String) -> Self
    var string: String { get set }
}

// MARK: Generic

public struct GenericSQLIdentifier: SQLIdentifier, ExpressibleByStringLiteral {
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
