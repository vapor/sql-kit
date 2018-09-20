/// Builds `SQLDropTable` queries.
///
///     conn.drop(table: Planet.self).run()
///
/// See `SQLQueryBuilder` for more information.
public final class SQLDropTableBuilder<Connectable>: SQLQueryBuilder
    where Connectable: SQLConnectable
{
    /// `DropTable` query being built.
    public var dropTable: Connectable.Connection.Query.DropTable
    
    /// See `SQLQueryBuilder`.
    public var connectable: Connectable
    
    /// See `SQLQueryBuilder`.
    public var query: Connectable.Connection.Query {
        return .dropTable(dropTable)
    }
    
    /// Creates a new `SQLDropTableBuilder`.
    public init(_ dropTable: Connectable.Connection.Query.DropTable, on connectable: Connectable) {
        self.dropTable = dropTable
        self.connectable = connectable
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
