public struct SQLGroupExpression: SQLExpression {
    public let expressions: [SQLExpression]
    
    public init(_ expression: SQLExpression) {
        self.expressions = [expression]
    }
    
    public init(_ expressions: [SQLExpression]) {
        self.expressions = expressions
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write("(")
        SQLList(self.expressions).serialize(to: &serializer)
        serializer.write(")")
    }
}
