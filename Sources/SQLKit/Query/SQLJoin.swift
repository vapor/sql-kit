///// `JOIN` clause.
public struct SQLJoin: SQLExpression {
    public var method: SQLExpression

    public var table: SQLExpression
    
    public var expression: SQLExpression

    /// Creates a new `SQLJoin`.
    public init(method: SQLExpression, table: SQLExpression, expression: SQLExpression) {
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
