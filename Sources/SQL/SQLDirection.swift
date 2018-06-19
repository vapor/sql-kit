public protocol SQLDirection: SQLSerializable {
    static var ascending: Self { get }
    static var descending: Self { get }
}

// MARK: Generic

public enum GenericSQLDirection: SQLDirection {
    /// See `SQLDirection`.
    public static var ascending: GenericSQLDirection {
        return ._ascending
    }
    
    /// See `SQLDirection`.
    public static var descending: GenericSQLDirection {
        return ._descending
    }
    
    case _ascending
    case _descending
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case ._ascending: return "ASC"
        case ._descending: return "DESC"
        }
    }
}
