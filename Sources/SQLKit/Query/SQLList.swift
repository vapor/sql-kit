public struct SQLList: SQLExpression {
    public var expressions: [any SQLExpression]
    public var separator: any SQLExpression

    @inlinable
    public init(_ expressions: [any SQLExpression], separator: any SQLExpression = SQLRaw(", ")) {
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
