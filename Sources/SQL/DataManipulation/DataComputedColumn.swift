/// A computed SQL column.
public struct DataComputedColumn {
    /// The SQL function to call.
    public var function: String

    /// The SQL data column parameters to the function. Can be none.
    public var keys: [DataManipulationKey]

    /// Creates a new SQL `DataComputedColumn`.
    public init(function: String, keys: [DataManipulationKey] = []) {
        self.function = function
        self.keys = keys
    }
}
