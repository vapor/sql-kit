public struct SQLList: SQLExpression {
    public let expressions: [SQLExpression]
    
    
    public init(_ expressions: [SQLExpression]) {
        self.expressions = expressions
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        
        var first = true
        for el in self.expressions {
            if !first {
                serializer.write(", ")
            }
            first = false
            el.serialize(to: &serializer)
        }
    }
}
