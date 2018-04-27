/// A computed SQL column.
public struct DataSubqueryColumn {
    /// The SQL sub-query
    public var query: String
    
    /// Creates a new SQL `DataSubqueryColumn`.
    public init(_ query: String) {
        self.query = query
    }
    
    /// Creates a new SQL `DataSubqueryColumn` from DataQuery.
    public init(_ query: DataQuery, on serializer: SQLSerializer) {
        var query = query
        query.limit = 1
        self.query = serializer.serialize(query: query)
    }
}
