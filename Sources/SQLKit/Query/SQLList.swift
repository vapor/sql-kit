public struct SQLList: SQLExpression {
    public let expressions: [SQLExpression]
    public let separator: SQLExpression

    public init(_ expressions: [SQLExpression], separator: SQLExpression = SQLRaw(", ")) {
        self.expressions = expressions
        self.separator = separator
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        var first = true
        for el in self.expressions {
            if !first {
                self.separator.serialize(to: &serializer)
            }
            first = false
            el.serialize(to: &serializer)
        }
    }
}
