/// SQL schema manipulation query (DDL: data-definition language).
public struct SchemaQuery {
    /// Creates a `CREATE` schema query.
    public static func create(table: String, columns: [SchemaColumn], foreignKeys: [SchemaForeignKey]) -> SchemaQuery {
        return .init(
            statement: .create,
            table: table,
            addColumns: columns,
            removeColumns: [],
            addForeignKeys: foreignKeys,
            removeForeignKeys: []
        )
    }

    /// Creates an `ALTER` schema query.
    public static func alter(
        table: String,
        addColumns: [SchemaColumn],
        removeColumns: [String],
        addForeignKeys: [SchemaForeignKey],
        removeForeignKeys: [String]
    ) -> SchemaQuery {
        return .init(
            statement: .alter,
            table: table,
            addColumns: addColumns,
            removeColumns: removeColumns,
            addForeignKeys: addForeignKeys,
            removeForeignKeys: removeForeignKeys
        )
    }

    /// Creates a `DROP` schema query.
    public static func drop(table: String) -> SchemaQuery {
        return SchemaQuery(
            statement: .drop,
            table: table,
            addColumns: [],
            removeColumns: [],
            addForeignKeys: [],
            removeForeignKeys: []
        )
    }

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
        addColumns: [SchemaColumn],
        removeColumns: [String],
        addForeignKeys: [SchemaForeignKey],
        removeForeignKeys: [String]
    ) {
        self.statement = statement
        self.table = table
        self.addColumns = addColumns
        self.removeColumns = removeColumns
        self.addForeignKeys = addForeignKeys
        self.removeForeignKeys = removeForeignKeys
    }
}
