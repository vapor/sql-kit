/// `ORDER BY` and constraint directions, i.e., `ASC`, `DESC`.
public protocol SQLDirection: SQLSerializable {
    /// Ascending order.
    static var ascending: Self { get }

    /// Descending order.
    static var descending: Self { get }

    /// Order in which NULL values come first.
    static var null: Self { get }

    /// Order in which NOT NULL values come first.
    static var notNull: Self { get }
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
    public static var null: GenericSQLDirection {
        return ._null
    }

    /// See `SQLDirection`.
    public static var notNull: GenericSQLDirection {
        return ._notNull
    }

    /// See `SQLDirection`.
    case _ascending

    /// See `SQLDirection`.
    case _descending

    /// See `SQLDirection`.
    case _null

    /// See `SQLDirection`.
    case _notNull

    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case ._ascending: return "ASC"
        case ._descending: return "DESC"
        case ._null: return "IS NULL"
        case ._notNull: return "IS NOT NULL"
        }
    }
}
