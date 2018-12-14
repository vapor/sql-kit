#warning("add collate")
#warning("add cast")

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
    associatedtype Identifier: SQLIdentifier
    
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
    
    /// Special expression type, all, `*`.
    static func all(table: Identifier?) -> Self
    
    static func alias(_ expression: Self, as: Identifier) -> Self
    
    /// Creates a new `SQLExpression` from a raw SQL string.
    /// This will be included in the query as is, no escaping.
    static func raw(_ string: String) -> Self
    
    /// If `true`, this expression equals `NULL`.
    var isNull: Bool { get }
}

// MARK: Convenience

extension SQLExpression {
    public static var all: Self {
        return .all(table: nil)
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
    
    static func coalesce(_ expressions: [Self]) -> Self {
        return self.function("COALESCE", expressions)
    }
    
    /// Convenience for creating a `COALESCE(foo)` function call (returns the first non-null expression).
    public static func coalesce(_ exprs: Self...) -> Self {
        return coalesce(exprs)
    }
}
