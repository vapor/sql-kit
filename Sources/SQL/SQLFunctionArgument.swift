public protocol SQLFunctionArgument: SQLSerializable {
    associatedtype Expression: SQLExpression
    static var all: Self { get }
    static func expression(_ expression: Expression) -> Self
}

// MARK: Generic

public enum GenericSQLFunctionArgument<Expression>: SQLFunctionArgument where Expression: SQLExpression {
    /// See `SQLFunctionArgument`.
    public static var all: GenericSQLFunctionArgument<Expression> {
        return ._all
    }
    
    /// See `SQLFunctionArgument`.
    public static func expression(_ expression: Expression) -> GenericSQLFunctionArgument<Expression> {
        return ._expression(expression)
    }
    
    case _all
    case _expression(Expression)
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case ._all: return "*"
        case ._expression(let expr): return expr.serialize(&binds)
        }
    }
}
