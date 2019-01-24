/// `CREATE INDEX` query.
///
/// See `SQLCreateIndexBuilder`.
public struct SQLCreateIndex: SQLExpression {
    public var name: SQLExpression
    
    public var table: SQLExpression?
    
    /// Type of index to create, see `SQLIndexModifier`.
    public var modifier: SQLExpression?
    
    /// Columns to index.
    public var columns: [SQLExpression]
    
    /// Creates a new `SQLCreateIndex.
    public init(name: SQLExpression) {
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
        serializer.write(" (")
        self.columns.serialize(to: &serializer, joinedBy: ", ")
        serializer.write(")")
    }
}
