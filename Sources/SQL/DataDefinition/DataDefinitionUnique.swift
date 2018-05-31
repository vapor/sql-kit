/// A unique column.
public struct DataDefinitionUnique {
    /// The column to be made unique
    public var columns: [DataManipulationQuery.Column]

    /// Creates a new `DataDefinitionUnique`.
    public init(columns: [DataManipulationQuery.Column]) {
        self.columns = columns
    }
}
