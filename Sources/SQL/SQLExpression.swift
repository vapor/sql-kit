public protocol SQLExpression: SQLSerializable {
    associatedtype Literal: SQLLiteral
    associatedtype Bind: SQLBind
    associatedtype ColumnIdentifier: SQLColumnIdentifier
    associatedtype BinaryOperator: SQLBinaryOperator
    associatedtype Function: SQLFunction
    associatedtype Subquery: SQLSerializable
    
    /// Literal strings, integers, and constants.
    static func literal(_ literal: Literal) -> Self
    
    /// Bound value.
    static func bind(_ bind: Bind) -> Self
    
    /// Column name.
    static func column(_ column: ColumnIdentifier) -> Self
    
    /// Binary expression.
    static func binary(_ lhs: Self, _ op: BinaryOperator, _ rhs: Self) -> Self
    
    /// Function.
    static func function(_ function: Function) -> Self
    
    /// Group of expressions.
    static func group(_ expressions: [Self]) -> Self
    
    /// `(SELECT ...)`
    static func subquery(_ subquery: Subquery) -> Self
    
    // FIXME: collate
    // FIXME: cast
    
    var isNull: Bool { get }
}

// MARK: Convenience

extension SQLExpression {
    public static func function(_ name: String, _ arg: Function.Argument) -> Self {
        return .function(.function(name, [arg]))
    }
    public static func function(_ name: String, _ args: [Function.Argument]) -> Self {
        return .function(.function(name, args))
    }
    
    public static func keyPath<T,V>(_ keyPath: KeyPath<T, V>) -> Self where T: SQLTable {
        return .column(.keyPath(keyPath))
    }
    
    public static func bind<E>(_ value: E) -> Self
        where E: Encodable
    {
        return .bind(.encodable(value))
    }
}

public func && <E>(_ lhs: E, _ rhs: E) -> E where E: SQLExpression {
    return E.binary(lhs, .and, rhs)
}

public func || <E>(_ lhs: E, _ rhs: E) -> E where E: SQLExpression {
    return E.binary(lhs, .or, rhs)
}

public func &= <E>(_ lhs: inout E?, _ rhs: E) where E: SQLExpression {
    if let l = lhs {
        lhs = l && rhs
    } else {
        lhs = rhs
    }
}

public func |= <E>(_ lhs: inout E?, _ rhs: E) where E: SQLExpression {
    if let l = lhs {
        lhs = l || rhs
    } else {
        lhs = rhs
    }
}


// MARK: Generic

public indirect enum GenericSQLExpression<Literal, Bind, ColumnIdentifier, BinaryOperator, Function, Subquery>: SQLExpression, ExpressibleByStringLiteral, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral
    where Literal: SQLLiteral, Bind: SQLBind, ColumnIdentifier: SQLColumnIdentifier, BinaryOperator: SQLBinaryOperator & Equatable, Function: SQLFunction, Subquery: SQLSerializable
{
    public typealias `Self` = GenericSQLExpression<Literal, Bind, ColumnIdentifier, BinaryOperator, Function, Subquery>

    public static func literal(_ literal: Literal) -> Self {
        return ._literal(literal)
    }
    
    public static func bind(_ bind: Bind) -> Self {
        return ._bind(bind)
    }

    public static func column(_ column: ColumnIdentifier) -> Self {
        return ._column(column)
    }

    public static func binary(_ lhs: Self, _ op: BinaryOperator, _ rhs: Self) -> Self {
        return ._binary(lhs, op, rhs)
    }

    public static func function(_ function: Function) -> Self {
        return ._function(function)
    }

    public static func group(_ expressions: [Self]) -> Self {
        return ._group(expressions)
    }

    public static func subquery(_ subquery: Subquery) -> Self {
        return ._subquery(subquery)
    }

    case _literal(Literal)
    case _bind(Bind)
    case _column(ColumnIdentifier)
    case _binary(`Self`, BinaryOperator, `Self`)
    case _function(Function)
    case _group([`Self`])
    case _subquery(Subquery)
    
    /// See `ExpressibleByFloatLiteral`.
    public init(floatLiteral value: Double) {
        self = ._literal(.numeric(value.description))
    }
    
    /// See `ExpressibleByStringLiteral`.
    public init(stringLiteral value: String) {
        self = ._literal(.string(value.description))
    }
    
    /// See `ExpressibleByIntegerLiteral`.
    public init(integerLiteral value: Int) {
        self = ._literal(.numeric(value.description))
    }

    public var isNull: Bool {
        switch self {
        case ._literal(let literal): return literal.isNull
        case ._bind(let bind): return bind.value.isNil
        default: return false
        }
    }
    
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case ._literal(let literal): return literal.serialize(&binds)
        case ._bind(let bind): return bind.serialize(&binds)
        case ._column(let column): return column.serialize(&binds)
        case ._binary(let lhs, let op, let rhs):
            switch rhs {
            case ._group(let group):
                switch group.count {
                case 0:
                    switch op {
                    case .in: return Self.literal(.boolean(.false)).serialize(&binds)
                    case .notIn: return Self.literal(.boolean(.true)).serialize(&binds)
                    default: break
                    }
                case 1:
                    switch op {
                    case .in: return Self._binary(lhs, .equal, group[0]).serialize(&binds)
                    case .notIn: return Self._binary(lhs, .notEqual, group[0]).serialize(&binds)
                    default: break
                    }
                default: break
                }
            default:
                if rhs.isNull {
                    switch op {
                    case .equal:
                        return lhs.serialize(&binds) + " IS NULL"
                    case .notEqual:
                        return lhs.serialize(&binds) + " IS NOT NULL"
                    default: break
                    }
                }
            }
            return lhs.serialize(&binds) + " " + op.serialize(&binds) + " " + rhs.serialize(&binds)
        case ._function(let function): return function.serialize(&binds)
        case ._group(let group):
            return "(" + group.map { $0.serialize(&binds) }.joined(separator: ", ") + ")"
        case ._subquery(let subquery):
            return "(" + subquery.serialize(&binds) + ")"
        }
    }
}

private extension Encodable {
    /// Returns `true` if this `Encodable` is `nil`.
    var isNil: Bool {
        guard let optional = self as? AnyOptionalType, optional.anyWrapped == nil else {
            return false
        }
        return true
    }
}
