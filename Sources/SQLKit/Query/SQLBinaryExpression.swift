public struct SQLBinaryExpression: SQLExpression {
    public let left: SQLExpression
    public let op: SQLExpression
    public let right: SQLExpression
    
    public init(left: SQLExpression, op: SQLExpression, right: SQLExpression) {
        self.left = left
        self.op = op
        self.right = right
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        self.left.serialize(to: &serializer)
        serializer.write(" ")
        self.op.serialize(to: &serializer)
        serializer.write(" ")
        self.right.serialize(to: &serializer)
    }
}

extension SQLBinaryExpression {
    public init(_ left: SQLExpression, _ op: SQLBinaryOperator, _ right: SQLExpression) {
        self.init(left: left, op: op, right: right)
    }
}
