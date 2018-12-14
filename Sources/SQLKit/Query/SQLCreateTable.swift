/// The `CREATE TABLE` command is used to create a new table in a database.
///
/// See `SQLCreateTableBuilder`.
public protocol SQLCreateTable: SQLSerializable {
    /// See `SQLTableIdentifier`.
    associatedtype Identifier: SQLIdentifier
    
    /// See `SQLColumnDefinition`.
    associatedtype ColumnDefinition: SQLColumnDefinition
    
    /// See `SQLTableConstraint`.
    associatedtype TableConstraint: SQLTableConstraint
    
    /// Creates a new `SQLCreateTable` query.
    static func createTable(name: Identifier) -> Self
    
    /// If the "TEMP" or "TEMPORARY" keyword occurs between the "CREATE" and "TABLE" then the new table is created in the temp database.
    var temporary: Bool { get set }
    
    /// It is usually an error to attempt to create a new table in a database that already contains a table, index or view of the
    /// same name. However, if the "IF NOT EXISTS" clause is specified as part of the CREATE TABLE statement and a table or view
    /// of the same name already exists, the CREATE TABLE command simply has no effect (and no error message is returned). An
    /// error is still returned if the table cannot be created because of an existing index, even if the "IF NOT EXISTS" clause is
    /// specified.
    var ifNotExists: Bool { get set }
    
    /// Name of table to create.
    var table: Identifier { get set }
    
    /// Columns to create.
    var columns: [ColumnDefinition] { get set }
    
    /// Table constraints, such as `FOREIGN KEY`, to add.
    var tableConstraints: [TableConstraint] { get set }
}
