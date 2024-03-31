/// Represents a "nested subpath" expression. At this time, this always represents a key path leading to a
/// specific value in a JSON object.
public struct SQLNestedSubpathExpression: SQLExpression {
    public var column: any SQLExpression
    public var path: [String]
    
    public init(column: any SQLExpression, path: [String]) {
        assert(!path.isEmpty)
        
        self.column = column
        self.path = path
    }
    
    public init(column: String, path: [String]) {
        self.init(column: SQLIdentifier(column), path: path)
    }

    public func serialize(to serializer: inout SQLSerializer) {
        serializer.dialect.nestedSubpathExpression(in: self.column, for: self.path)?.serialize(to: &serializer)
    }
}
