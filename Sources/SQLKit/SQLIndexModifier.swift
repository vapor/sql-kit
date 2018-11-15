/// SQL index modifier, i.e., `UNIQUE`.
public protocol SQLIndexModifier: SQLSerializable {
    /// `UNIQUE`.
    static var unique: Self { get }
}

/// Generic implementation of `SQLIndexModifier`.
public enum GenericSQLIndexModifier: SQLIndexModifier {
    /// See `SQLIndexModifier`.
    public static var unique: GenericSQLIndexModifier {
        return ._unique
    }
    
    /// See `SQLIndexModifier`.
    case _unique
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case ._unique: return "UNIQUE"
        }
    }
}
