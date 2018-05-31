/// SQL schema manipulation query (DDL: data-definition language).
public struct DDL {
    /// Statement type to perform, e.g., create or alter.
    public var statement: Statement

    /// Table name to create, modify, or delete.
    public var table: String

    /// A collection of columns to be added when this query is executed.
    /// - note: This property may be ignored by some `DataDefinitionStatement` types.
    public var createColumns: [ColumnDefinition]

    /// A collection of column names to be removed when this query is executed.
    /// - note: This property may be ignored by some `DataDefinitionStatement` types.
    public var deleteColumns: [ColumnDefinition]

    /// A collection of foreign keys to be added when this query is executed.
    /// - note: This property may be ignored by some `DataDefinitionStatement` types.
    public var createConstraints: [Constraint]

    /// A collection of foreign key names to be removed when this query is executed.
    /// - note: This property may be ignored by some `DataDefinitionStatement` types.
    public var deleteConstraints: [Constraint]

    /// Creates a new `DataDefinitionQuery`.
    public init(statement: Statement, table: String, createColumns: [ColumnDefinition], deleteColumns: [ColumnDefinition], createConstraints: [Constraint], deleteConstraints: [Constraint]) {
        self.statement = statement
        self.table = table
        self.createColumns = createColumns
        self.deleteColumns = deleteColumns
        self.createConstraints = createConstraints
        self.deleteConstraints = deleteConstraints
    }
}
