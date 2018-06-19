public protocol SQLDistinct: SQLSerializable {
    static var all: Self { get }
    static var distinct: Self { get }
    var isDistinct: Bool { get }
}

// MARK: Default

extension SQLDistinct {
    public func serialize(_ binds: inout [Encodable]) -> String {
        if isDistinct {
            return "DISTINCT"
        } else {
            return "ALL"
        }
    }
}

// MARK: Generic

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
    
    case _distinct
    case _all
}
