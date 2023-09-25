///// `JOIN` clause.
public struct SQLJoin: SQLExpression {
    public var method: any SQLExpression

    public var table: any SQLExpression
    
    public var expression: any SQLExpression

    /// Creates a new `SQLJoin`.
    @inlinable
    public init(method: any SQLExpression, table: any SQLExpression, expression: any SQLExpression) {
        self.method = method
        self.table = table
        self.expression = expression
    }

    public func serialize(to serializer: inout SQLSerializer) {
        self.method.serialize(to: &serializer)
        serializer.write(" JOIN ")
        self.table.serialize(to: &serializer)
        serializer.write(" ON ")
        self.expression.serialize(to: &serializer)
    }
}
