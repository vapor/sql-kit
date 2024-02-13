public struct SQLGroupExpression: SQLExpression {
    public let expressions: [any SQLExpression]
    
    @inlinable
    public init(_ expression: any SQLExpression) {
        self.expressions = [expression]
    }
    
    @inlinable
    public init(_ expressions: [any SQLExpression]) {
        self.expressions = expressions
    }
    
    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write("(")
        SQLList(self.expressions).serialize(to: &serializer)
        serializer.write(")")
    }
}
