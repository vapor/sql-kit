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
