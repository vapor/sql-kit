/// SQL schema manipulation query (DDL: data-definition language).
public struct DataDefinitionQuery {
    /// Statement type to perform, e.g., create or alter.
    public var statement: DataDefinitionStatement

    /// Table name to create, modify, or delete.
    public var table: String

    /// A collection of columns to be added when this query is executed.
    /// - note: This property may be ignored by some `DataDefinitionStatement` types.
    public var createColumns: [DataDefinitionColumn]

    /// A collection of column names to be removed when this query is executed.
    /// - note: This property may be ignored by some `DataDefinitionStatement` types.
    public var deleteColumns: [DataColumn]

    /// A collection of foreign keys to be added when this query is executed.
    /// - note: This property may be ignored by some `DataDefinitionStatement` types.
    public var createConstraints: [DataDefinitionConstraint]

    /// A collection of foreign key names to be removed when this query is executed.
    /// - note: This property may be ignored by some `DataDefinitionStatement` types.
    public var deleteConstraints: [DataDefinitionConstraint]

    /// Creates a new `DataDefinitionQuery`.
    public init(
        statement: DataDefinitionStatement,
        table: String,
        createColumns: [DataDefinitionColumn] = [],
        deleteColumns: [DataColumn] = [],
        createConstraints: [DataDefinitionConstraint] = [],
        deleteConstraints: [DataDefinitionConstraint] = []
    ) {
        self.statement = statement
        self.table = table
        self.createColumns = createColumns
        self.deleteColumns = deleteColumns
        self.createConstraints = createConstraints
        self.deleteConstraints = deleteConstraints
    }
}
