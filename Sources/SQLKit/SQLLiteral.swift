/// Literal expression value, i.e., `DEFAULT`, `FALSE`, `42`, etc.
public protocol SQLLiteral: SQLSerializable, ExpressibleByStringLiteral {
    /// See `SQLDefaultLiteral`.
    associatedtype DefaultLiteral: SQLDefaultLiteral
    
    /// See `SQLBoolLiteral`.
    associatedtype BoolLiteral: SQLBoolLiteral
    
    /// Creates a new `SQLLiteral` from a string.
    static func string(_ string: String) -> Self
    
    /// Creates a new `SQLLiteral` from a numeric string (no quotes).
    static func numeric(_ string: String) -> Self
    
    /// Creates a new null `SQLLiteral`, i.e., `NULL`.
    static var null: Self { get }
    
    /// Creates a new default `SQLLiteral` literal, i.e., `DEFAULT` or sometimes `NULL`.
    static func `default`(_ default: DefaultLiteral) -> Self
    
    /// Creates a new boolean `SQLLiteral`, i.e., `FALSE` or sometimes `0`.
    static func boolean(_ bool: BoolLiteral) -> Self
    
    /// If `true`, this `SQLLiteral` represents `NULL`.
    var isNull: Bool { get }
}

// MARK: Convenience

extension SQLLiteral {
    /// `DEFAULT`.
    public static var `default`: Self {
        return .default(.default)
    }
}

// MARK: Generic

/// Generic implementation of `SQLLiteral`.
public enum GenericSQLLiteral<DefaultLiteral, BoolLiteral>: SQLLiteral, ExpressibleByStringLiteral, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral where
    DefaultLiteral: SQLDefaultLiteral, BoolLiteral: SQLBoolLiteral
{
    /// See `SQLLiteral`.
    public static func string(_ string: String) -> GenericSQLLiteral {
        return ._string(string)
    }
    
    /// See `SQLLiteral`.
    public static func numeric(_ string: String) -> GenericSQLLiteral {
        return ._numeric(string)
    }
    
    /// See `SQLLiteral`.
    public static var null: GenericSQLLiteral {
        return ._null
    }
    
    /// See `SQLLiteral`.
    public static func `default`(_ default: DefaultLiteral) -> GenericSQLLiteral {
        return ._default(`default`)
    }
    
    /// See `SQLLiteral`.
    public static func boolean(_ bool: BoolLiteral) -> GenericSQLLiteral {
        return ._boolean(bool)
    }

    /// See `ExpressibleByStringLiteral`.
    public init(stringLiteral value: String) {
        self = .string(value)
    }

    /// See `ExpressibleByFloatLiteral`.
    public init(floatLiteral value: Double) {
        self = .numeric(value.description)
    }

    /// See `ExpressibleByIntegerLiteral`.
    public init(integerLiteral value: Int) {
        self = .numeric(value.description)
    }

    
    /// See `SQLLiteral`.
    case _string(String)
    
    /// See `SQLLiteral`.
    case _numeric(String)
    
    /// See `SQLLiteral`.
    case _null
    
    /// See `SQLLiteral`.
    case _default(DefaultLiteral)
    
    /// See `SQLLiteral`.
    case _boolean(BoolLiteral)
    
    
    /// See `SQLLiteral`.
    public var isNull: Bool {
        switch self {
        case ._null: return true
        default: return false
        }
    }
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case ._boolean(let bool): return bool.serialize(&binds)
        case ._null: return "NULL"
        case ._default(let d): return d.serialize(&binds)
        case ._numeric(let string): return string
        case ._string(let string): return "'" + string + "'"
        }
    }
}
