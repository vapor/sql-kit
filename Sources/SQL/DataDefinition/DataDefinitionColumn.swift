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

public struct DataDefinitionDataType: ExpressibleByStringLiteral {
    /// VARCHAR
    public var name: String

    /// (a, b, c)
    public var parameters: [String]

    /// UNSIGNED, PRIMARY KEY
    public var attributes: [String]

    /// Creates a new `DataDefinitionDataType`.
    public init(name: String, parameters: [String] = [], attributes: [String] = []) {
        self.name = name
        self.parameters = parameters
        self.attributes = attributes
    }

    /// See `ExpressibleByStringLiteral`.
    public init(stringLiteral value: String) {
        self.init(name: value)
    }
}
