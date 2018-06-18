public protocol SQLLiteral: SQLSerializable {
    static func string(_ string: String) -> Self
    static func numeric(_ string: String) -> Self
    static var null: Self { get }
    static var `default`: Self { get }
    static func boolean(_ bool: Bool) -> Self
    
    var isNull: Bool { get }
}

// MARK: Generic

public enum GenericSQLLiteral: SQLLiteral, ExpressibleByStringLiteral, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
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
    public static var `default`: GenericSQLLiteral {
        return ._default
    }
    
    /// See `SQLLiteral`.
    public static func boolean(_ bool: Bool) -> GenericSQLLiteral {
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

    case _string(String)
    case _numeric(String)
    case _null
    case _default
    case _boolean(Bool)
    
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
        case ._boolean(let bool): return bool.description.uppercased()
        case ._null: return "NULL"
        case ._default: return "DEFAULT"
        case ._numeric(let string): return string
        case ._string(let string): return "'" + string + "'"
        }
    }
}
