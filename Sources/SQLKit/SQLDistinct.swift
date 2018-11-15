/// Determines whether duplicate rows are included in `SQLSelect` queries.
public protocol SQLDistinct: SQLSerializable {
    /// `ALL`. Explicitly include all rows. This is the default.
    static var all: Self { get }
    
    /// `DISTINCT`. Exclude duplicate rows. 
    static var distinct: Self { get }
}

// MARK: Generic

/// Generic implementation of `SQLDistinct`.
public enum GenericSQLDistinct: SQLDistinct {
    /// See `SQLDistinct`.
    public static var all: GenericSQLDistinct {
        return ._all
    }
    
    /// See `SQLDistinct`.
    public static var distinct: GenericSQLDistinct {
        return ._distinct
    }
    
    /// See `SQLDistinct`.
    public var isDistinct: Bool {
        switch self {
        case ._all: return false
        case ._distinct: return true
        }
    }
    
    /// See `SQLDistinct`.
    case _distinct
    
    /// See `SQLDistinct`.
    case _all
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        if isDistinct {
            return "DISTINCT"
        } else {
            return "ALL"
        }
    }
}
