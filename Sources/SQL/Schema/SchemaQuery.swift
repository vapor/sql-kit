/// SQL schema manipulation query (DDL: data-definition language).
public struct SchemaQuery {
    /// Statement type to perform, e.g., create or alter.
    public var statement: SchemaStatement

    /// Table name to create, modify, or delete.
    public var table: String

    /// A collection of columns to be added when this query is executed.
    /// - note: This property may be ignored by some `SchemaStatement` types.
    public var addColumns: [SchemaColumn]

    /// A collection of column names to be removed when this query is executed.
    /// - note: This property may be ignored by some `SchemaStatement` types.
    public var removeColumns: [String]

    /// A collection of foreign keys to be added when this query is executed.
    /// - note: This property may be ignored by some `SchemaStatement` types.
    public var addForeignKeys: [SchemaForeignKey]

    /// A collection of foreign key names to be removed when this query is executed.
    /// - note: This property may be ignored by some `SchemaStatement` types.
    public var removeForeignKeys: [String]

    /// Creates a new `SchemaQuery`.
    public init(
        statement: SchemaStatement,
        table: String,
        addColumns: [SchemaColumn] = [],
        removeColumns: [String] = [],
        addForeignKeys: [SchemaForeignKey] = [],
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
