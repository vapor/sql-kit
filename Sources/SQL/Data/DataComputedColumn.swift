/// A computed SQL column.
public struct DataComputedColumn {
    /// The SQL function to call.
    public var function: String

    /// The SQL data column parameters to the function. Can be none.
    public var columns: [DataColumn]

    /// Creates a new SQL `DataComputedColumn`.
    public init(function: String, columns: [DataColumn] = []) {
        self.function = function
        self.columns = columns
    }
}
