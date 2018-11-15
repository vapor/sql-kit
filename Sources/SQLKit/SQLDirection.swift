/// `ORDER BY` and constraint directions, i.e., `ASC`, `DESC`.
public protocol SQLDirection: SQLSerializable {
    /// Ascending order.
    static var ascending: Self { get }
    
    /// Descending order.
    static var descending: Self { get }
}

// MARK: Generic

/// Generic implementation of `SQLDirection`.
public enum GenericSQLDirection: SQLDirection {
    /// See `SQLDirection`.
    public static var ascending: GenericSQLDirection {
        return ._ascending
    }
    
    /// See `SQLDirection`.
    public static var descending: GenericSQLDirection {
        return ._descending
    }
    
    /// See `SQLDirection`.
    case _ascending
    
    /// See `SQLDirection`.
    case _descending
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case ._ascending: return "ASC"
        case ._descending: return "DESC"
        }
    }
}
