/// A single column in a schema statement.
public struct SchemaColumn {
    /// The column's name.
    public var name: String

    /// The column's data type, including all attributes.
    public var dataType: String

    /// Creates a new `SchemaColumn`.
    public init(name: String, dataType: String) {
        self.name = name
        self.dataType = dataType
    }
}
