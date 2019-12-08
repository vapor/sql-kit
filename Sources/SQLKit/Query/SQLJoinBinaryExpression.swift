public struct SQLJoinBinaryExpression: SQLExpression {
    public let left: SQLExpression
    public let right: SQLExpression
    public let op: SQLExpression

    public init(from: SQLColumn, to: SQLColumn) {
        self.left = from
        self.right = to
        op = SQLBinaryOperator.equal
    }

    public func serialize(to serializer: inout SQLSerializer) {
        self.left.serialize(to: &serializer)
        serializer.write(" ")
        self.op.serialize(to: &serializer)
        serializer.write(" ")
        self.right.serialize(to: &serializer)
    }
}
