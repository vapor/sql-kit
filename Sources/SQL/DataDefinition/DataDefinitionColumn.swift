/// A single column in a DDL statement.
public struct DataDefinitionColumn {
    /// The column's name.
    public var name: String

    /// The column's data type.
    public var dataType: DataDefinitionDataType

    /// Creates a new `DataDefinitionColumn`.
    public init(name: String, dataType: DataDefinitionDataType) {
        self.name = name
        self.dataType = dataType
    }
}
