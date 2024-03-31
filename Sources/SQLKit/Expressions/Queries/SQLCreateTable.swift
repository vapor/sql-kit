/// The `CREATE TABLE` command is used to create a new table in a database.
///
/// See ``SQLCreateTableBuilder``.
public struct SQLCreateTable: SQLExpression {
    /// Name of table to create.
    public var table: any SQLExpression
    
    /// If the "TEMP" or "TEMPORARY" keyword occurs between the "CREATE" and "TABLE" then the new table is created in the temp database.
    public var temporary: Bool
    
    /// It is usually an error to attempt to create a new table in a database that already contains a table, index or view of the
    /// same name. However, if the "IF NOT EXISTS" clause is specified as part of the CREATE TABLE statement and a table or view
    /// of the same name already exists, the CREATE TABLE command simply has no effect (and no error message is returned). An
    /// error is still returned if the table cannot be created because of an existing index, even if the "IF NOT EXISTS" clause is
    /// specified.
    public var ifNotExists: Bool
    
    /// Columns to create.
    public var columns: [any SQLExpression]
    
    /// Table constraints, such as `FOREIGN KEY`, to add.
    public var tableConstraints: [any SQLExpression]
    
    /// A subquery which, when present, is used to fill in the contents of the new table.
    public var asQuery: (any SQLExpression)?
    
    /// Creates a new `SQLCreateTable` query.
    @inlinable
    public init(name: any SQLExpression) {
        self.table = name
        self.temporary = false
        self.ifNotExists = false
        self.columns = []
        self.tableConstraints = []
        self.asQuery = nil
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("CREATE")
            if self.temporary {
                $0.append("TEMPORARY")
            }
            $0.append("TABLE")
            if self.ifNotExists {
                if $0.dialect.supportsIfExists {
                    $0.append("IF NOT EXISTS")
                } else {
                    $0.database.logger.warning("\($0.dialect.name) does not support IF NOT EXISTS")
                }
            }
            // There's no reason not to have a space between the table name and its definitions, but not
            // having it is the established behavior, which the tests check for.
            $0.append(SQLList([self.table, SQLGroupExpression(self.columns + self.tableConstraints)], separator: SQLRaw("")))
            if let asQuery = self.asQuery {
                $0.append("AS")
                $0.append(asQuery)
            }
        }
    }
}
