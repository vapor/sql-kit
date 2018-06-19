public protocol SQLLiteral: SQLSerializable {
    associatedtype Default: SQLDefaultLiteral
    static func string(_ string: String) -> Self
    static func numeric(_ string: String) -> Self
    static var null: Self { get }
    static func `default`(_ default: Default) -> Self
    static func boolean(_ bool: Bool) -> Self
    
    var isNull: Bool { get }
}

extension SQLLiteral {
    public static var `default`: Self {
        return .default(.default())
    }
}

public protocol SQLDefaultLiteral: SQLSerializable {
    static func `default`() -> Self
}

// MARK: Generic

public enum GenericSQLLiteral<Default>: SQLLiteral, ExpressibleByStringLiteral, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral where
    Default: SQLDefaultLiteral
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
    public static func `default`(_ default: Default) -> GenericSQLLiteral<Default> {
        return ._default(`default`)
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
    case _default(Default)
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
        case ._default(let d): return d.serialize(&binds)
        case ._numeric(let string): return string
        case ._string(let string): return "'" + string + "'"
        }
    }
}
