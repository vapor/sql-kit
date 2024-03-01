/// `JOIN` clause.
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

    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append(self.method, "JOIN")
            $0.append(self.table, "ON", self.expression)
        }
    }
}
