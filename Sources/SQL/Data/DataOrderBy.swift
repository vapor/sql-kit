/// A SQL `ORDER BY` that determines the order of results.
public struct DataOrderBy {
    /// The columns to order.
    public var columns: [DataColumn]

    /// The direction to order the results.
    public var direction: DataOrderByDirection

    /// Creates a new SQL `DataOrderBy`
    public init(columns: [DataColumn], direction: DataOrderByDirection) {
        self.columns = columns
        self.direction = direction
    }
}
