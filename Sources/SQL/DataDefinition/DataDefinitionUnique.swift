/// A unique column.
public struct DataDefinitionUnique {
    /// The column to be made unique
    public var columns: [DataColumn]

    /// Creates a new `DataDefinitionUnique`.
    public init(columns: [DataColumn]) {
        self.columns = columns
    }
}
