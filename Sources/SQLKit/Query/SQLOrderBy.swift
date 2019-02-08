/// `ORDER BY` clause.
public struct SQLOrderBy: SQLExpression {
    public var expression: SQLExpression
    
    public var direction: SQLExpression
    
    /// Creates a new `SQLOrderBy`.
    public init(expression: SQLExpression, direction: SQLExpression) {
        self.expression = expression
        self.direction = direction
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        self.expression.serialize(to: &serializer)
        serializer.write(" ")
        self.direction.serialize(to: &serializer)
    }
}
