/// SQL schema manipulation query (DDL: data-definition language).
public struct DataDefinitionQuery {
    /// Statement type to perform, e.g., create or alter.
    public var statement: DataDefinitionStatement

    /// Table name to create, modify, or delete.
    public var table: String

    /// A collection of columns to be added when this query is executed.
    /// - note: This property may be ignored by some `DataDefinitionStatement` types.
    public var addColumns: [DataDefinitionColumn]

    /// A collection of column names to be removed when this query is executed.
    /// - note: This property may be ignored by some `DataDefinitionStatement` types.
    public var removeColumns: [String]

    /// A collection of foreign keys to be added when this query is executed.
    /// - note: This property may be ignored by some `DataDefinitionStatement` types.
    public var addForeignKeys: [DataDefinitionForeignKey]

    /// A collection of foreign key names to be removed when this query is executed.
    /// - note: This property may be ignored by some `DataDefinitionStatement` types.
    public var removeForeignKeys: [String]

    /// Creates a new `DataDefinitionQuery`.
    public init(
        statement: DataDefinitionStatement,
        table: String,
        addColumns: [DataDefinitionColumn] = [],
        removeColumns: [String] = [],
        addForeignKeys: [DataDefinitionForeignKey] = [],
        removeForeignKeys: [String] = []
    ) {
        self.statement = statement
        self.table = table
        self.addColumns = addColumns
        self.removeColumns = removeColumns
        self.addForeignKeys = addForeignKeys
        self.removeForeignKeys = removeForeignKeys
    }
}
