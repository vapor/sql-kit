/// A unique column.
public struct DataDefinitionUnique {
    /// The column to be made unique
    public var columns: [DML.Column]

    /// Creates a new `DataDefinitionUnique`.
    public init(columns: [DML.Column]) {
        self.columns = columns
    }
}
