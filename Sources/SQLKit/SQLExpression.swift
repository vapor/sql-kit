/// A SQL expression, i.e., a column name, value placeholder, function,
/// subquery, or binary expression.
///
/// These expression are evaluated by the SQL engine and are used throughout many
/// types in this package.
///
/// This type is also highly recursive. Binary expressions, for example, have a left
/// and right sub expression and so on. Function expressions have zero or more arguments
/// that are also expressions.
public protocol SQLExpression: SQLSerializable, ExpressibleByStringLiteral, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    /// See `SQLLiteral`.
    associatedtype Literal: SQLLiteral
    
    /// See `SQLBind`.
    associatedtype Bind: SQLBind
    
    /// See `SQLColumnIdentifier`.
    associatedtype ColumnIdentifier: SQLColumnIdentifier
    
    /// See `SQLBinaryOperator`.
    associatedtype BinaryOperator: SQLBinaryOperator
    
    /// See `SQLTableIdentifier`.
    associatedtype TableIdentifier: SQLTableIdentifier
    
    /// See `SQLTableIdentifier`.
    associatedtype Identifier: SQLTableIdentifier
    
    /// See `SQLSerializable`.
    /// Ideally this would be constraint to `SQLQuery`, but that creates a cyclic reference.
    associatedtype Subquery: SQLSerializable
    
    /// Literal strings, integers, and constants.
    static func literal(_ literal: Literal) -> Self
    
    /// Bound value.
    static func bind(_ bind: Bind) -> Self
    
    /// Column name.
    static func column(_ column: ColumnIdentifier) -> Self
    
    /// Binary expression.
    static func binary(_ lhs: Self, _ op: BinaryOperator, _ rhs: Self) -> Self
    
    /// Creates a new `SQLFunction`.
    static func function(_ name: String, _ args: [Self]) -> Self
    
    /// Group of expressions.
    static func group(_ expressions: [Self]) -> Self
    
    /// `(SELECT ...)`
    static func subquery(_ subquery: Subquery) -> Self
    
    // Coalesce.
    static func coalesce(_ expressions: [Self]) -> Self
    
    /// Special expression type, all, `*`.
    static func all(_ table: TableIdentifier?) -> Self
    
    static func alias(_ expression: Self, as: Identifier) -> Self
    
    // FIXME: collate
    // FIXME: cast
    
    /// If `true`, this expression equals `NULL`.
    var isNull: Bool { get }
}

// MARK: Convenience

extension SQLExpression {
    public static var all: Self {
        return .all(nil)
    }
    
    /// Convenience for creating a function call.
    ///
    ///     .function("UUID")
    ///
    public static func function(_ name: String) -> Self {
        return .function(name, [])
    }
    
    /// Convenience for creating a `SUM(foo)` function call on a given KeyPath.
    ///
    ///     .sum(\Planet.mass)
    ///
    public static func sum(_ column: Self) -> Self {
        return .function("SUM", [column])
    }
    
    /// Convenience for creating a `COUNT(foo)` function call on a given KeyPath.
    ///
    ///     .count(\Planet.id)
    ///
    public static func count(_ column: Self) -> Self {
        return .function("COUNT", [column])
    }

    /// Variadic convenience method for creating a group of expressions.
    ///
    ///     .group(a, b, c)
    ///
    public static func group(_ exprs: Self...) -> Self {
        return group(exprs)
    }
    
    /// Bound value. Shorthand for `.bind(.encodable(...))`.
    public static func bind<E>(_ value: E) -> Self
        where E: Encodable
    {
        return bind(.encodable(value))
    }
    
    /// Bound value. Shorthand for `.bind(.encodable(...))`.
    public static func binds<E>(_ values: [E]) -> Self
        where E: Encodable
    {
        return group(values.map { .bind($0) })
    }
    
    /// Convenience for creating a `COALESCE(foo)` function call (returns the first non-null expression).
    public static func coalesce(_ exprs: Self...) -> Self {
        return coalesce(exprs)
    }
}

///// See `SQLExpression`.
//public func && <E>(_ lhs: E, _ rhs: E) -> E where E: SQLExpression {
//    return E.binary(lhs, .and, rhs)
//}
//
///// See `SQLExpression`.
//public func || <E>(_ lhs: E, _ rhs: E) -> E where E: SQLExpression {
//    return E.binary(lhs, .or, rhs)
//}
//
///// See `SQLExpression`.
//public func &= <E>(_ lhs: inout E?, _ rhs: E) where E: SQLExpression {
//    if let l = lhs {
//        lhs = l && rhs
//    } else {
//        lhs = rhs
//    }
//}
//
///// See `SQLExpression`.
//public func |= <E>(_ lhs: inout E?, _ rhs: E) where E: SQLExpression {
//    if let l = lhs {
//        lhs = l || rhs
//    } else {
//        lhs = rhs
//    }
//}

//extension SQLSelectExpression {
//    /// Creates a column identifier `SQLSelectExpression` from a key path and optional alias.
//    public static func keyPath<T,V>(_ keyPath: KeyPath<T, V>, as alias: Identifier? = nil) -> Self where T: SQLTable {
//        return self.expression(.column(.keyPath(keyPath)), alias: alias)
//    }
//}

//// MARK: Generic
//
///// Generic implementation of `SQLExpression`.
//public indirect enum GenericSQLExpression<Literal, Bind, ColumnIdentifier, BinaryOperator, Function, Subquery>: SQLExpression
//    where Literal: SQLLiteral,
//    Bind: SQLBind,
//    ColumnIdentifier: SQLColumnIdentifier,
//    BinaryOperator: SQLBinaryOperator & Equatable,
//    Function: SQLFunction,
//    Subquery: SQLSerializable
//{
//    /// Convenience alias for self.
//    public typealias `Self` = GenericSQLExpression<Literal, Bind, ColumnIdentifier, BinaryOperator, Function, Subquery>
//
//    /// See `SQLExpression`.
//    public static func literal(_ literal: Literal) -> Self {
//        return ._literal(literal)
//    }
//
//    /// See `SQLExpression`.
//    public static func bind(_ bind: Bind) -> Self {
//        return ._bind(bind)
//    }
//
//    /// See `SQLExpression`.
//    public static func column(_ column: ColumnIdentifier) -> Self {
//        return ._column(column)
//    }
//
//    /// See `SQLExpression`.
//    public static func binary(_ lhs: Self, _ op: BinaryOperator, _ rhs: Self) -> Self {
//        return ._binary(lhs, op, rhs)
//    }
//
//    /// See `SQLExpression`.
//    public static func function(_ function: Function) -> Self {
//        return ._function(function)
//    }
//
//    /// See `SQLExpression`.
//    public static func group(_ expressions: [Self]) -> Self {
//        return ._group(expressions)
//    }
//
//    /// See `SQLExpression`.
//    public static func subquery(_ subquery: Subquery) -> Self {
//        return ._subquery(subquery)
//    }
//
//    /// See `SQLExpression`.
//    public static func coalesce(_ expressions: [Self]) -> Self {
//        return ._coalesce(expressions)
//    }
//
//    /// See `SQLExpression`.
//    case _literal(Literal)
//
//    /// See `SQLExpression`.
//    case _bind(Bind)
//
//    /// See `SQLExpression`.
//    case _column(ColumnIdentifier)
//
//    /// See `SQLExpression`.
//    case _binary(`Self`, BinaryOperator, `Self`)
//
//    /// See `SQLExpression`.
//    case _function(Function)
//
//    /// See `SQLExpression`.
//    case _group([`Self`])
//
//    /// See `SQLExpression`.
//    case _subquery(Subquery)
//
//    /// See `SQLExpression`.
//    case _coalesce([`Self`])
//
//    /// See `ExpressibleByFloatLiteral`.
//    public init(floatLiteral value: Double) {
//        self = ._literal(.numeric(value.description))
//    }
//
//    /// See `ExpressibleByIntegerLiteral`.
//    public init(integerLiteral value: Int) {
//        self = ._literal(.numeric(value.description))
//    }
//
//    /// See `SQLExpression`.
//    public var isNull: Bool {
//        switch self {
//        case ._literal(let literal): return literal.isNull
//        default: return false
//        }
//    }
//
//    /// See `SQLSerializable`.
//    public func serialize(_ binds: inout [Encodable]) -> String {
//        switch self {
//        case ._literal(let literal): return literal.serialize(&binds)
//        case ._bind(let bind): return bind.serialize(&binds)
//        case ._column(let column): return column.serialize(&binds)
//        case ._binary(let lhs, let op, let rhs):
//            switch rhs {
//            case ._group(let group):
//                switch group.count {
//                case 0:
//                    switch op {
//                    case .in: return Self.literal(.boolean(.false)).serialize(&binds)
//                    case .notIn: return Self.literal(.boolean(.true)).serialize(&binds)
//                    default: break
//                    }
//                case 1:
//                    switch op {
//                    case .in: return Self._binary(lhs, .equal, group[0]).serialize(&binds)
//                    case .notIn: return Self._binary(lhs, .notEqual, group[0]).serialize(&binds)
//                    default: break
//                    }
//                default: break
//                }
//            case ._literal(let literal):
//                if literal.isNull {
//                    switch op {
//                    case .equal:
//                        return lhs.serialize(&binds) + " IS NULL"
//                    case .notEqual:
//                        return lhs.serialize(&binds) + " IS NOT NULL"
//                    default: break
//                    }
//                }
//            default: break
//            }
//            return lhs.serialize(&binds) + " " + op.serialize(&binds) + " " + rhs.serialize(&binds)
//        case ._function(let function): return function.serialize(&binds)
//        case ._group(let group):
//            return "(" + group.map { $0.serialize(&binds) }.joined(separator: ", ") + ")"
//        case ._subquery(let subquery):
//            return "(" + subquery.serialize(&binds) + ")"
//        case ._coalesce(let expressions):
//            return "COALESCE(" + expressions.map { $0.serialize(&binds) }.joined(separator: ", ") + ")"
//        }
//    }
//}
