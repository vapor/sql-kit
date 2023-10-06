public struct SQLColumn: SQLExpression {
    public var name: any SQLExpression
    public var table: (any SQLExpression)?
    
    @inlinable
    public init(_ name: String, table: String? = nil) {
        self.init(SQLIdentifier(name), table: table.flatMap(SQLIdentifier.init(_:)))
    }
    
    @inlinable
    public init(_ name: any SQLExpression, table: (any SQLExpression)? = nil) {
        self.name = name
        self.table = table
    }
    
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        if let table = self.table {
            table.serialize(to: &serializer)
            serializer.write(".")
        }
        self.name.serialize(to: &serializer)
    }
}
