/// A SQL `DataOrderBy`, determines the order of results.
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

/// Available order by directions for a `DataOrderBy`.
public enum DataOrderByDirection {
    /// DESC
    case ascending

    /// ASC
    case descending

    /// Custom string that will be interpolated into the SQL query.
    /// note: Be careful about SQL injection when using this.
    case custom(String)
}
