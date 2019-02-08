public struct SQLDropIndex: SQLExpression {
    public var name: SQLExpression
    
    public init(name: SQLExpression) {
        self.name = name
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write("DROP INDEX ")
        self.name.serialize(to: &serializer)
    }
}
