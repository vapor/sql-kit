/// A single column in a DDL statement.
public struct DataDefinitionColumn {
    /// The column's name.
    public var name: String

    /// The column's data type.
    public var dataType: DataDefinitionDataType

    /// A collection of attributes to apply to this column.
    public var attributes: [String]

    /// Creates a new `DataDefinitionColumn`.
    public init(name: String, dataType: DataDefinitionDataType, attributes: [String] = []) {
        self.name = name
        self.dataType = dataType
        self.attributes = attributes
    }
}

public struct DataDefinitionDataType {
    /// VARCHAR
    public let name: String

    /// (a, b, c)
    public let parameters: [String]
}
