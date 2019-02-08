public struct SQLTableConstraint: SQLExpression {
    public var columns: [SQLExpression]
    public var algorithm: SQLExpression
    public var name: SQLExpression?
    
    /// Creates a new `SQLColumnConstraint` from desired algorithm and identifier.
    public init(columns: [SQLExpression], algorithm: SQLExpression, name: SQLExpression?) {
        self.columns = columns
        self.algorithm = algorithm
        self.name = name
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        if let name = self.name {
            serializer.write("CONSTRAINT ")
            name.serialize(to: &serializer)
            serializer.write(" ")
        }
        self.algorithm.serialize(to: &serializer)
        serializer.write(" ")
        SQLGroupExpression(self.columns).serialize(to: &serializer)
    }
}
