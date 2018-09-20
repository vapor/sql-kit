/// Builds `SQLDropTable` queries.
///
///     conn.drop(table: Planet.self).run()
///
/// See `SQLQueryBuilder` for more information.
public final class SQLDropTableBuilder<Connection>: SQLQueryBuilder
    where Connection: SQLConnectable
{
    /// `DropTable` query being built.
    public var dropTable: Connection.Query.DropTable
    
    /// See `SQLQueryBuilder`.
    public var connection: Connection
    
    /// See `SQLQueryBuilder`.
    public var query: Connection.Query {
        return .dropTable(dropTable)
    }
    
    /// Creates a new `SQLDropTableBuilder`.
    public init(_ dropTable: Connection.Query.DropTable, on connection: Connection) {
        self.dropTable = dropTable
        self.connection = connection
    }
    
    /// The optional `IF EXISTS` clause suppresses the error that would normally
    /// result if the table does not exist.
    public func ifExists() -> Self {
        dropTable.ifExists = true
        return self
    }
}

// MARK: Connection

extension SQLConnectable {
    /// Creates a new `SQLDropTable` builder.
    ///
    ///     conn.drop(table: Planet.self).run()
    ///
    public func drop<Table>(table: Table.Type) -> SQLDropTableBuilder<Self>
        where Table: SQLTable
    {
        return .init(.dropTable(.table(Table.self)), on: self)
    }
}
