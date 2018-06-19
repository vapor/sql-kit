public protocol SQLSelectExpression: SQLSerializable {
    associatedtype Expression: SQLExpression
    associatedtype Identifier: SQLIdentifier
    
    static var all: Self { get }
    static func allTable(_ table: String) -> Self
    static func expression(_ expression: Expression, alias: Identifier?) -> Self
    
    var isAll: Bool { get }
    var allTable: String? { get }
    var expression: (expression: Expression, alias: Identifier?)? { get }
}

// MARK: Convenience

extension SQLSelectExpression {
    public static func count(_ arg: Expression.Function.Argument = .all, as alias: Identifier? = nil) -> Self {
        return .function("COUNT", [arg], as: alias)
    }
    
    public static func function(_ name: String, _ args: [Expression.Function.Argument], as alias: Identifier? = nil) -> Self {
        return .expression(.function(.function(name, args)), alias: alias)
    }
}

// MARK: Generic

public enum GenericSQLSelectExpression<Expression, Identifier>: SQLSelectExpression, ExpressibleByStringLiteral where
    Expression: SQLExpression, Identifier: SQLIdentifier
{
    /// See `SQLSelectExpression`.
    public typealias `Self` = GenericSQLSelectExpression<Expression, Identifier>
    
    /// See `SQLSelectExpression`.
    public static var all: Self {
        return ._all
    }
    
    /// See `SQLSelectExpression`.
    public static func allTable(_ table: String) ->Self {
        return ._allTable(table)
    }
    
    /// See `SQLSelectExpression`.
    public static func expression(_ expression: Expression, alias: Identifier?) -> Self {
        return ._expression(expression, alias: alias)
    }
    
    /// See `SQLSelectExpression`.
    public var isAll: Bool {
        switch self {
        case ._all: return true
        default: return false
        }
    }
    
    /// See `SQLSelectExpression`.
    public var allTable: String? {
        switch self {
        case ._allTable(let table): return table
        default: return nil
        }
    }
    
    /// See `SQLSelectExpression`.
    public var expression: (expression: Expression, alias: Identifier?)? {
        switch self {
        case ._expression(let expr, let alias): return (expr, alias)
        default: return nil
        }
    }
    
    /// See `ExpressibleByStringLiteral`.
    public init(stringLiteral value: String) {
        self = ._expression(.column(.column(nil, .identifier(value))), alias: nil)
    }
    
    /// `*`
    case _all
    
    /// `table.*`
    case _allTable(String)
    
    /// `md5(a) AS hash`
    case _expression(Expression, alias: Identifier?)
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case ._all: return "*"
        case ._allTable(let table): return table + ".*"
        case ._expression(let expr, let alias):
            switch alias {
            case .none: return expr.serialize(&binds)
            case .some(let alias): return expr.serialize(&binds) + " AS " + alias.serialize(&binds)
            }
        }
    }
}
