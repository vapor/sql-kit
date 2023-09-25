/// `CREATE INDEX` query.
///
/// See ``SQLCreateIndexBuilder``.
public struct SQLCreateIndex: SQLExpression {
    public var name: any SQLExpression
    
    public var table: (any SQLExpression)?
    
    /// Type of index to create, see `SQLIndexModifier`.
    public var modifier: (any SQLExpression)?
    
    /// Columns to index.
    public var columns: [any SQLExpression]
    
    /// Creates a new `SQLCreateIndex.
    @inlinable
    public init(name: any SQLExpression) {
        self.name = name
        self.table = nil
        self.modifier = nil
        self.columns = []
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write("CREATE")
        if let modifier = self.modifier {
            serializer.write(" ")
            modifier.serialize(to: &serializer)
        }
        serializer.write(" INDEX ")
        self.name.serialize(to: &serializer)
        if let table = self.table {
            serializer.write(" ON ")
            table.serialize(to: &serializer)
        }
        serializer.write(" ")
        SQLGroupExpression(self.columns).serialize(to: &serializer)
    }
}
