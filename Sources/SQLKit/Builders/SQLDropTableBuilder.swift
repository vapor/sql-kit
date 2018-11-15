/// Builds `SQLDropTable` queries.
///
///     conn.drop(table: Planet.self).run()
///
/// See `SQLQueryBuilder` for more information.
public final class SQLDropTableBuilder<Database>: SQLQueryBuilder
    where Database: SQLDatabase
{
    /// `DropTable` query being built.
    public var dropTable: Database.Query.DropTable
    
    /// See `SQLQueryBuilder`.
    public var database: Database
    
    /// See `SQLQueryBuilder`.
    public var query: Database.Query {
        return .dropTable(dropTable)
    }
    
    /// Creates a new `SQLDropTableBuilder`.
    public init(_ dropTable: Database.Query.DropTable, on database: Database) {
        self.dropTable = dropTable
        self.database = database
    }
    
    /// The optional `IF EXISTS` clause suppresses the error that would normally
    /// result if the table does not exist.
    public func ifExists() -> Self {
        dropTable.ifExists = true
        return self
    }
}

// MARK: Connection

extension SQLDatabase {
    /// Creates a new `SQLDropTable` builder.
    ///
    ///     conn.drop(table: Planet.self).run()
    ///
    public func drop(table: Query.DropTable.Identifier) -> SQLDropTableBuilder<Self> {
        return .init(.dropTable(name: table), on: self)
    }
}
