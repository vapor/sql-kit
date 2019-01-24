/// The `CREATE TABLE` command is used to create a new table in a database.
///
/// See `SQLCreateTableBuilder`.
public struct SQLCreateTable: SQLExpression {
    /// Name of table to create.
    public var table: SQLExpression
    
    /// If the "TEMP" or "TEMPORARY" keyword occurs between the "CREATE" and "TABLE" then the new table is created in the temp database.
    public var temporary: Bool
    
    /// It is usually an error to attempt to create a new table in a database that already contains a table, index or view of the
    /// same name. However, if the "IF NOT EXISTS" clause is specified as part of the CREATE TABLE statement and a table or view
    /// of the same name already exists, the CREATE TABLE command simply has no effect (and no error message is returned). An
    /// error is still returned if the table cannot be created because of an existing index, even if the "IF NOT EXISTS" clause is
    /// specified.
    public var ifNotExists: Bool
    
    /// Columns to create.
    public var columns: [SQLExpression]
    
    /// Table constraints, such as `FOREIGN KEY`, to add.
    public var tableConstraints: [SQLExpression]
    
    /// Creates a new `SQLCreateTable` query.
    public init(name: SQLExpression) {
        self.table = name
        self.temporary = false
        self.ifNotExists = false
        self.columns = []
        self.tableConstraints = []
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write("CREATE ")
        if self.temporary {
            serializer.write("TEMPORARY ")
        }
        serializer.write("TABLE ")
        if self.ifNotExists {
            serializer.write("IF NOT EXISTS ")
        }
        self.table.serialize(to: &serializer)
        serializer.write(" (")
        (columns + tableConstraints).serialize(to: &serializer, joinedBy: ", ")
        serializer.write(")")
    }
}
