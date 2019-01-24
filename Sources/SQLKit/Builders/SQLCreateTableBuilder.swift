/// Builds `SQLCreateTable` queries.
///
///    conn.create(table: Planet.self).ifNotExists()
///        .column(for: \Planet.id, .primaryKey)
///        .column(for: \Planet.galaxyID, .references(\Galaxy.id))
///        .run()
///
/// See `SQLColumnBuilder` and `SQLQueryBuilder` for more information.
public final class SQLCreateTableBuilder: SQLQueryBuilder, SQLColumnBuilder {
    /// `CreateTable` query being built.
    public var createTable: SQLCreateTable
    
    /// See `SQLQueryBuilder`.
    public var database: SQLDatabase
    
    /// See `SQLQueryBuilder`.
    public var query: SQLExpression {
        return self.createTable
    }
    
    /// See `SQLColumnBuilder`.
    public var columns: [SQLExpression] {
        get { return createTable.columns }
        set { createTable.columns = newValue }
    }
    
    /// Creates a new `SQLCreateTableBuilder`.
    public init(_ createTable: SQLCreateTable, on database: SQLDatabase) {
        self.createTable = createTable
        self.database = database
    }
    
    
    /// If the "TEMP" or "TEMPORARY" keyword occurs between the "CREATE" and "TABLE" then the new table is created in the temp database.
    public func temporary() -> Self {
        createTable.temporary = true
        return self
    }
    
    /// It is usually an error to attempt to create a new table in a database that already contains a table, index or view of the
    /// same name. However, if the "IF NOT EXISTS" clause is specified as part of the CREATE TABLE statement and a table or view
    /// of the same name already exists, the CREATE TABLE command simply has no effect (and no error message is returned). An
    /// error is still returned if the table cannot be created because of an existing index, even if the "IF NOT EXISTS" clause is
    /// specified.
    public func ifNotExists() -> Self {
        createTable.ifNotExists = true
        return self
    }
}

// MARK: Connection

extension SQLDatabase {
    /// Creates a new `SQLCreateTableBuilder`.
    ///
    ///     conn.create(table: "planets")...
    ///
    /// - parameters:
    ///     - table: Table to create.
    /// - returns: `CreateTableBuilder`.
    public func create(table: String) -> SQLCreateTableBuilder {
        return self.create(table: SQLIdentifier(table))
    }
    
    /// Creates a new `SQLCreateTableBuilder`.
    ///
    ///     conn.create(table: SQLIdentifier("planets"))...
    ///
    /// - parameters:
    ///     - table: Table to create.
    /// - returns: `CreateTableBuilder`.
    public func create(table: SQLExpression) -> SQLCreateTableBuilder {
        return .init(.init(name: table), on: self)
    }
}
