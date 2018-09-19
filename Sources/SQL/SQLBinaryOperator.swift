/// SQL binary expression operators, i.e., `==`, `!=`, `AND`, `+`, etc.
///
/// See `SQLExpression`.
public protocol SQLBinaryOperator: SQLSerializable {
    /// `=` or `==`
    static var equal: Self { get }
    
    /// `!=` or `<>`
    static var notEqual: Self { get }
    
    /// `>`
    static var greaterThan: Self { get }
    
    /// `<`
    static var lessThan: Self { get }
    
    /// `>=`
    static var greaterThanOrEqual: Self { get }
    
    /// `<=`
    static var lessThanOrEqual: Self { get }
    
    /// `LIKE`
    static var like: Self { get }
    
    /// `NOT LIKE`
    static var notLike: Self { get }
    
    /// `IN`
    static var `in`: Self { get }
    
    /// `NOT IN`
    static var `notIn`: Self { get }
    
    /// `AND`
    static var and: Self { get }
    
    /// `OR`
    static var or: Self { get }
    
    /// `||`
    static var concatenate: Self { get }
    
    /// `*`
    static var multiply: Self { get }
    
    /// `/`
    static var divide: Self { get }
    
    /// `%`
    static var modulo: Self { get }
    
    /// `+`
    static var add: Self { get }
    
    /// `-`
    static var subtract: Self { get }
}

// MARK: Generic

/// Generic implementation of `SQLBinaryOperator`.
public enum GenericSQLBinaryOperator: SQLBinaryOperator, Equatable {
    /// See `SQLBinaryOperator`.
    public static var equal: GenericSQLBinaryOperator { return ._equal }
    
    /// See `SQLBinaryOperator`.
    public static var notEqual: GenericSQLBinaryOperator { return ._notEqual }
    
    /// See `SQLBinaryOperator`.
    public static var greaterThan: GenericSQLBinaryOperator { return ._greaterThan }
    
    /// See `SQLBinaryOperator`.
    public static var lessThan: GenericSQLBinaryOperator { return ._lessThan }
    
    /// See `SQLBinaryOperator`.
    public static var greaterThanOrEqual: GenericSQLBinaryOperator { return ._greaterThanOrEqual }
    
    /// See `SQLBinaryOperator`.
    public static var lessThanOrEqual: GenericSQLBinaryOperator { return ._lessThanOrEqual }
    
    /// See `SQLBinaryOperator`.
    public static var like: GenericSQLBinaryOperator { return ._like }
    
    /// See `SQLBinaryOperator`.
    public static var notLike: GenericSQLBinaryOperator { return ._notLike }
    
    /// See `SQLBinaryOperator`.
    public static var `in`: GenericSQLBinaryOperator { return ._in }
    
    /// See `SQLBinaryOperator`.
    public static var `notIn`: GenericSQLBinaryOperator { return ._notIn }
    
    
    /// See `SQLBinaryOperator`.
    public static var and: GenericSQLBinaryOperator { return ._and }
    
    /// See `SQLBinaryOperator`.
    public static var or: GenericSQLBinaryOperator { return ._or }
    
    
    /// See `SQLBinaryOperator`.
    public static var concatenate: GenericSQLBinaryOperator { return ._concatenate }
    
    
    /// See `SQLBinaryOperator`.
    public static var multiply: GenericSQLBinaryOperator { return ._multiply }
    
    /// See `SQLBinaryOperator`.
    public static var divide: GenericSQLBinaryOperator { return ._divide }
    
    /// See `SQLBinaryOperator`.
    public static var modulo: GenericSQLBinaryOperator { return ._modulo }
    
    /// See `SQLBinaryOperator`.
    public static var add: GenericSQLBinaryOperator { return ._add }
    
    /// See `SQLBinaryOperator`.
    public static var subtract: GenericSQLBinaryOperator { return ._subtract }
    
    
    /// `||`
    case _concatenate
    
    /// `*`
    case _multiply
    
    /// `/`
    case _divide
    
    /// `%`
    case _modulo
    
    /// `+`
    case _add
    
    /// `-`
    case _subtract
    
    /// `<<`
    case _bitwiseShiftLeft
    
    /// `>>`
    case _bitwiseShiftRight
    
    /// `&`
    case _bitwiseAnd
    
    /// `|`
    case _bitwiseOr
    
    /// `<`
    case _lessThan
    
    /// `<=`
    case _lessThanOrEqual
    
    /// `>`
    case _greaterThan
    
    /// `>=`
    case _greaterThanOrEqual
    
    /// `=` or `==`
    case _equal
    
    /// `!=` or `<>`
    case _notEqual
    
    /// `AND`
    case _and
    
    /// `OR`
    case _or
    
    /// `IS`
    case _is
    
    /// `IS NOT`
    case _isNot
    
    /// `IN`
    case _in
    
    /// `NOT IN`
    case _notIn
    
    /// `LIKE`
    case _like
    
    /// `NOT LIKE`
    case _notLike
    
    /// `GLOB`
    case _glob
    
    /// `NOT GLOB`
    case _notGlob
    
    /// `MATCH`
    case _match
    
    /// `NOT MATCH`
    case _notMatch
    
    /// `REGEXP`
    case _regexp
    
    /// `NOT REGEXP`
    case _notRegexp
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case ._add: return "+"
        case ._bitwiseAnd: return "&"
        case ._bitwiseOr: return "|"
        case ._bitwiseShiftLeft: return "<<"
        case ._bitwiseShiftRight: return ">>"
        case ._concatenate: return "||"
        case ._divide: return "/"
        case ._equal: return "="
        case ._greaterThan: return ">"
        case ._greaterThanOrEqual: return ">="
        case ._lessThan: return "<"
        case ._lessThanOrEqual: return "<="
        case ._modulo: return "%"
        case ._multiply: return "*"
        case ._notEqual: return "!="
        case ._subtract: return "-"
        case ._and: return "AND"
        case ._or: return "OR"
        case ._in: return "IN"
        case ._notIn: return "NOT IN"
        case ._is: return "IS"
        case ._isNot: return "IS NOT"
        case ._like: return "LIKE"
        case ._glob: return "GLOB"
        case ._match: return "MATCH"
        case ._regexp: return "REGEXP"
        case ._notLike: return "NOT LIKE"
        case ._notGlob: return "NOT GLOB"
        case ._notMatch: return "NOT MATCH"
        case ._notRegexp: return "NOT REGEXP"
        }
    }
}

// MARK: Operator

/// See `SQLBinaryOperator`.
public func == <T,V,E>(_ lhs: KeyPath<T, V>, _ rhs: V) -> E
    where T: SQLTable, V: Encodable, E: SQLExpression
{
    if rhs.isNil {
        return E.binary(.column(.keyPath(lhs)), .equal, .literal(.null))
    }
    return E.binary(.column(.keyPath(lhs)), .equal, .bind(.encodable(rhs)))
}

/// See `SQLBinaryOperator`.
public func != <T,V,E>(_ lhs: KeyPath<T, V>, _ rhs: V) -> E
    where T: SQLTable, V: Encodable, E: SQLExpression
{
    if rhs.isNil {
        return E.binary(.column(.keyPath(lhs)), .notEqual, .literal(.null))
    }
    return E.binary(.column(.keyPath(lhs)), .notEqual, .bind(.encodable(rhs)))
}

/// See `SQLBinaryOperator`.
public func == <A, B, C, D, E>(_ lhs: KeyPath<A, B>, _ rhs: KeyPath<C, D>) -> E
    where A: SQLTable, B: Encodable, C: SQLTable, D: Encodable, E: SQLExpression
{
    return E.binary(.column(.keyPath(lhs)), .equal, .column(.keyPath(rhs)))
}

/// See `SQLBinaryOperator`.
public func != <A, B, C, D, E>(_ lhs: KeyPath<A, B>, _ rhs: KeyPath<C, D>) -> E
    where A: SQLTable, B: Encodable, C: SQLTable, D: Encodable, E: SQLExpression
{
    return E.binary(.column(.keyPath(lhs)), .notEqual, .column(.keyPath(rhs)))
}

internal extension Encodable {
    /// Returns `true` if this `Encodable` is `nil`.
    var isNil: Bool {
        guard let optional = self as? AnyOptionalType, optional.anyWrapped == nil else {
            return false
        }
        return true
    }
}
