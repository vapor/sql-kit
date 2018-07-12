/// Argument to a `SQLFunction`.
public protocol SQLFunctionArgument: SQLSerializable {
    /// See `SQLExpression`.
    associatedtype Expression: SQLExpression
    
    /// Special function argument, `*`.
    static var all: Self { get }
    
    /// Creates a new `SQLFunctionArgument` with the supplied expression.
    static func expression(_ expression: Expression) -> Self
}

// MARK: Generic

/// Generic implementation of `SQLFunctionArgument`.
public enum GenericSQLFunctionArgument<Expression>: SQLFunctionArgument where Expression: SQLExpression {
    /// See `SQLFunctionArgument`.
    public static var all: GenericSQLFunctionArgument<Expression> {
        return ._all
    }
    
    /// See `SQLFunctionArgument`.
    public static func expression(_ expression: Expression) -> GenericSQLFunctionArgument<Expression> {
        return ._expression(expression)
    }
    
    /// See `SQLFunctionArgument`.
    case _all
    
    /// See `SQLFunctionArgument`.
    case _expression(Expression)
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case ._all: return "*"
        case ._expression(let expr): return expr.serialize(&binds)
        }
    }
}
