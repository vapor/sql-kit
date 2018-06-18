public protocol SQLIdentifier: SQLSerializable {
    static func identifier(_ string: String) -> Self
    var string: String { get set }
}

// MARK: Generic

public struct GenericSQLIdentifier: SQLIdentifier {
    public static func identifier(_ string: String) -> GenericSQLIdentifier {
        return self.init(string: string)
    }
    
    public var string: String
    
    public func serialize(_ binds: inout [Encodable]) -> String {
        return "\"" + string + "\""
    }
}
