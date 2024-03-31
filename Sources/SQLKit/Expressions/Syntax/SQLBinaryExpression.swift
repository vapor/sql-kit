public struct SQLBinaryExpression: SQLExpression {
    public let left: any SQLExpression
    public let op: any SQLExpression
    public let right: any SQLExpression
    
    @inlinable
    public init(left: any SQLExpression, op: any SQLExpression, right: any SQLExpression) {
        self.left = left
        self.op = op
        self.right = right
    }
    
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append(self.left)
            $0.append(self.op)
            $0.append(self.right)
        }
    }
}

extension SQLBinaryExpression {
    @inlinable
    public init(_ left: any SQLExpression, _ op: SQLBinaryOperator, _ right: any SQLExpression) {
        self.init(left: left, op: op, right: right)
    }
}
