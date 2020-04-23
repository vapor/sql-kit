public struct SQLColumn: SQLExpression {
    public var name: SQLExpression
    public var table: SQLExpression?
    
    public init(_ name: String, table: String? = nil) {
        self.init(SQLIdentifier(name), table: table.flatMap(SQLIdentifier.init(_:)))
    }
    
    public init(_ name: SQLExpression, table: SQLExpression? = nil) {
        self.name = name
        self.table = table
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        if let table = self.table {
            table.serialize(to: &serializer)
            serializer.write(".")
        }
        self.name.serialize(to: &serializer)
    }
}
