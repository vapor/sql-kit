public final class SQLAlterTableBuilder<Connection>: SQLQueryBuilder, SQLColumnBuilder
    where Connection: DatabaseQueryable, Connection.Query: SQLQuery
{
    /// See `SQLColumnBuilder`.
    public typealias ColumnDefinition = Connection.Query.AlterTable.ColumnDefinition
    
    /// `AlterTable` query being built.
    public var alterTable: Connection.Query.AlterTable

    /// See `SQLQueryBuilder`.
    public var connection: Connection

    /// See `SQLQueryBuilder`.
    public var query: Connection.Query {
        return .alterTable(alterTable)
    }
    
    /// See `SQLColumnBuilder`.
    public var columns: [Connection.Query.AlterTable.ColumnDefinition] {
        get { return alterTable.columns }
        set { alterTable.columns = newValue }
    }

    /// Creates a new `SQLAlterTableBuilder`.
    public init(_ alterTable: Connection.Query.AlterTable, on connection: Connection) {
        self.alterTable = alterTable
        self.connection = connection
    }
}

// MARK: Connection

extension DatabaseQueryable where Query: SQLQuery {
    /// Creates a new `AlterTableBuilder`.
    ///
    ///     conn.alter(table: Planet.self)...
    ///
    /// - parameters:
    ///     - table: Table to alter.
    /// - returns: `AlterTableBuilder`.
    public func alter<Table>(table: Table.Type) -> SQLAlterTableBuilder<Self>
        where Table: SQLTable
    {
        return .init(.alterTable(.table(Table.self)), on: self)
    }
}

