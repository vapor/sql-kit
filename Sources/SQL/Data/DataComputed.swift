/// A computed SQL field.
public struct DataComputed {
    /// The SQL function to call.
    public var function: String

    /// The SQL-column parameters to the function. Can be none.
    public var columns: [DataColumn]

    /// The key to label this computed field.
    public var key: String?

    /// Creates a SQL `DataComputed`
    public init(function: String, columns: [DataColumn] = [], key: String? = nil) {
        self.function = function
        self.columns = columns
        self.key = key
    }
}

