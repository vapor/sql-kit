public struct SQLQualifiedTable: SQLExpression {
    public var table: any SQLExpression
    public var space: (any SQLExpression)?
    
    public init(_ table: String, space: String? = nil) {
        self.init(SQLIdentifier(table), space: space.flatMap(SQLIdentifier.init(_:)))
    }
    
    public init(_ table: any SQLExpression, space: (any SQLExpression)? = nil) {
        self.table = table
        self.space = space
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        if let space = self.space {
            space.serialize(to: &serializer)
            serializer.write(".")
        }
        self.table.serialize(to: &serializer)
    }
}
