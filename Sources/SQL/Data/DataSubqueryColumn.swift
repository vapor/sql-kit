/// A computed SQL column.
public struct DataSubqueryColumn {
    /// The SQL sub-query
    public var query: DataQuery
    
    /// Creates a new SQL `DataSubqueryColumn` from DataQuery.
    public init(_ query: DataQuery) {
        var query = query
        query.limit = 1
        self.query = query
    }
}
