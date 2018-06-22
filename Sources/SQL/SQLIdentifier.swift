public protocol SQLIdentifier: SQLSerializable {
    static func identifier(_ string: String) -> Self
    static func identifier(_ string: String, isKeyword: Bool) -> Self
    var string: String { get set }
}

// MARK: Generic

public struct GenericSQLIdentifier: SQLIdentifier {
    public static func identifier(_ string: String) -> GenericSQLIdentifier {
        return self.init(string: string, isKeyword: false)
    }

    public static func identifier(_ string: String, isKeyword: Bool) -> GenericSQLIdentifier {
        return self.init(string: string, isKeyword: isKeyword)
    }

    public var string: String
    public var isKeyword: Bool
    
    public func serialize(_ binds: inout [Encodable]) -> String {
        if isKeyword {
            return string
        } else {
            return "\"" + string + "\""
        }
    }
}
