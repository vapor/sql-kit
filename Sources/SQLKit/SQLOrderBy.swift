/// `ORDER BY` clause.
public protocol SQLOrderBy: SQLSerializable {
    /// See `SQLExpression`.
    associatedtype Expression: SQLExpression
    
    /// See `SQLDirection`.
    associatedtype Direction: SQLDirection
    
    /// Creates a new `SQLOrderBy`.
    static func orderBy(_ expression: Expression, _ direction: Direction) -> Self
}

// MARK: Generic

/// Generic implementation of `SQLOrderBy`.
public struct GenericSQLOrderBy<Expression, Direction>: SQLOrderBy where Expression: SQLExpression, Direction: SQLDirection {
    /// See `SQLOrderBy`.
    public static func orderBy(_ expression: Expression, _ direction: Direction) -> GenericSQLOrderBy<Expression, Direction> {
        return .init(expression: expression, direction: direction)
    }
    
    /// See `SQLOrderBy`.
    public var expression: Expression
    
    /// See `SQLOrderBy`.
    public var direction: Direction
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        return expression.serialize(&binds) + " " + direction.serialize(&binds)
    }
}
