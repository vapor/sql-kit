public protocol SQLIndexModifier: SQLSerializable {
    static var unique: Self { get }
}

public enum GenericSQLIndexModifier: SQLIndexModifier {
    /// See `SQLIndexModifier`.
    public static var unique: GenericSQLIndexModifier {
        return ._unique
    }
    
    case _unique
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case ._unique: return "UNIQUE"
        }
    }
}
