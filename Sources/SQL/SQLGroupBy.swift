/// `GROUP BY` clause.
public protocol SQLGroupBy: SQLSerializable {
    /// See `SQLExpression`.
    associatedtype Expression: SQLExpression
    
    /// Creates a new `SQLGroupBy` with the supplied expression.
    static func groupBy(_ expression: Expression) -> Self
}

// MARK: Generic

/// Generic implementation of `SQLGroupBy`.
public struct GenericSQLGroupBy<Expression>: SQLGroupBy where Expression: SQLExpression {
    /// See `SQLGroupBy`.
    public static func groupBy(_ expression: Expression) -> GenericSQLGroupBy<Expression> {
        return .init(expression: expression)
    }
    
    /// See `SQLGroupBy`.
    public var expression: Expression
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        return expression.serialize(&binds)
    }
}
