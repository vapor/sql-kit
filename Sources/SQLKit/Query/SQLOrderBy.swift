/// `ORDER BY` clause.
public struct SQLOrderBy: SQLExpression {
    public var expression: any SQLExpression
    
    public var direction: any SQLExpression
    
    /// Creates a new `SQLOrderBy`.
    @inlinable
    public init(expression: any SQLExpression, direction: any SQLExpression) {
        self.expression = expression
        self.direction = direction
    }
    
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        self.expression.serialize(to: &serializer)
        serializer.write(" ")
        self.direction.serialize(to: &serializer)
    }
}
