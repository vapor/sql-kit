/// Specifies columns in a `SELECT` statement's result set.
///
/// See `SQLSelectBuilder`.
public protocol SQLSelectExpression: SQLSerializable, ExpressibleByStringLiteral {
    /// See `SQLExpression`.
    associatedtype Expression: SQLExpression
    
    /// See `SQLTableIdentifier`.
    associatedtype TableIdentifier: SQLTableIdentifier
    
    /// See `SQLIdentifier`.
    associatedtype Identifier: SQLIdentifier
    
    /// Creates a new `SQLSelectExpression` for all columns, i.e., `*`.
    static var all: Self { get }
    
    /// Creates a new `SQLSelectExpression` for all columns in a specified table, i.e., `table.*`.
    static func allTable(_ table: TableIdentifier) -> Self
    
    /// Creates a new `SQLSelectExpression` using a `SQLExpression` with optional alias.
    static func expression(_ expression: Expression, alias: Identifier?) -> Self
}

// MARK: Convenience

extension SQLSelectExpression {
    /// Creates a new `SQLSelectExpression` using the SQL `COUNT` function.
    ///
    ///     conn.select()
    ///         .column(.count())
    ///
    /// - parameters:
    ///     - arg: Argument to count function. Defaults to `all`, i.e., `*`.
    ///     - alias: Optional alias for the function's resulting value.
    public static func count(_ arg: Expression.Function.Argument = .all, as alias: Identifier? = nil) -> Self {
        return .function("COUNT", [arg], as: alias)
    }
    
    /// Creates a new `SQLSelectExpression` using a SQL function.
    ///
    ///     conn.select()
    ///         .column(.function("COUNT", [.all])
    ///
    /// - parameters:
    ///     - name: Name of the function.
    ///     - args: Array of arguments to the function. Defaults to `all`, i.e., `*`.
    ///     - alias: Optional alias for the function's resulting value.
    public static func function(_ name: String, _ args: [Expression.Function.Argument], as alias: Identifier? = nil) -> Self {
        return .expression(.function(.function(name, args)), alias: alias)
    }
}

// MARK: Generic

/// Generic implementation of `SQLSelectExpression`.
public enum GenericSQLSelectExpression<Expression, Identifier, TableIdentifier>: SQLSelectExpression where
    Expression: SQLExpression, Identifier: SQLIdentifier, TableIdentifier: SQLTableIdentifier
{
    /// See `SQLSelectExpression`.
    public typealias `Self` = GenericSQLSelectExpression<Expression, Identifier, TableIdentifier>
    
    /// See `SQLSelectExpression`.
    public static var all: Self {
        return ._all
    }
    
    /// See `SQLSelectExpression`.
    public static func allTable(_ table: TableIdentifier) ->Self {
        return ._allTable(table)
    }
    
    /// See `SQLSelectExpression`.
    public static func expression(_ expression: Expression, alias: Identifier?) -> Self {
        return ._expression(expression, alias: alias)
    }
    
    /// See `ExpressibleByStringLiteral`.
    public init(stringLiteral value: String) {
        self = ._expression(.column(.column(nil, .identifier(value))), alias: nil)
    }
    
    /// `*`
    case _all
    
    /// `table.*`
    case _allTable(TableIdentifier)
    
    /// `md5(a) AS hash`
    case _expression(Expression, alias: Identifier?)
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case ._all: return "*"
        case ._allTable(let table): return table.serialize(&binds) + ".*"
        case ._expression(let expr, let alias):
            switch alias {
            case .none: return expr.serialize(&binds)
            case .some(let alias): return expr.serialize(&binds) + " AS " + alias.serialize(&binds)
            }
        }
    }
}
