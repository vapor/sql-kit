public protocol SQLGroupBy: SQLSerializable {
    associatedtype Expression: SQLExpression
    static func groupBy(_ expression: Expression) -> Self
}

// MARK: Generic

public struct GenericSQLGroupBy<Expression>: SQLGroupBy where Expression: SQLExpression {
    public static func groupBy(_ expression: Expression) -> GenericSQLGroupBy<Expression> {
        return .init(expression: expression)
    }
    
    public var expression: Expression
    
    public func serialize(_ binds: inout [Encodable]) -> String {
        return expression.serialize(&binds)
    }
}
