public protocol SQLOrderBy: SQLSerializable {
    associatedtype Expression: SQLExpression
    associatedtype Direction: SQLDirection
    static func orderBy(_ expression: Expression, _ direction: Direction) -> Self
}

// MARK: Generic

public struct GenericSQLOrderBy<Expression, Direction>: SQLOrderBy where Expression: SQLExpression, Direction: SQLDirection {
    public static func orderBy(_ expression: Expression, _ direction: Direction) -> GenericSQLOrderBy<Expression, Direction> {
        return .init(expression: expression, direction: direction)
    }
    
    public var expression: Expression
    public var direction: Direction
    
    public func serialize(_ binds: inout [Encodable]) -> String {
        return expression.serialize(&binds) + " " + direction.serialize(&binds)
    }
}
