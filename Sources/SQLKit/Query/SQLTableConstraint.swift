public struct SQLTableConstraint: SQLExpression {
    /// Serialized after the name and algorithm but before the modifier
    public var columns: [SQLExpression]?
    public var algorithm: SQLExpression
    public var name: SQLExpression?
    /// The last thing serialized in the constraint expression
    public var modifier: SQLExpression?
    
    /// Creates a new `SQLTableConstraint` from desired algorithm and identifier.
    public init(columns: [SQLExpression]?, algorithm: SQLExpression, name: SQLExpression?, modifier: SQLExpression? = nil) {
        self.columns = columns
        self.algorithm = algorithm
        self.name = name
        self.modifier = modifier
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        if let name = self.name {
            serializer.write("CONSTRAINT ")
            name.serialize(to: &serializer)
            serializer.write(" ")
        }
        self.algorithm.serialize(to: &serializer)
        if let columns = self.columns {
            serializer.write(" ")
            SQLGroupExpression(columns).serialize(to: &serializer)
        }
        if let modifier = self.modifier {
            serializer.write(" ")
            modifier.serialize(to: &serializer)
        }
    }
}
