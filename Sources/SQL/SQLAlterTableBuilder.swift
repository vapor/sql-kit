/// Builds `ALTER TABLE` queries.
///
///     conn.alter(table: Planet.self)
///         .column(for: \.name)
///         .run()
///
/// See `SQLColumnBuilder` for more information.
public final class SQLAlterTableBuilder<Connectable>: SQLQueryBuilder, SQLColumnBuilder
    where Connectable: SQLConnectable
{
    /// See `SQLColumnBuilder`.
    public typealias ColumnDefinition = Connectable.Connection.Query.AlterTable.ColumnDefinition
    
    /// `SQLAlterTable` query being built.
    public var alterTable: Connectable.Connection.Query.AlterTable

    /// See `SQLQueryBuilder`.
    public var connectable: Connectable

    /// See `SQLQueryBuilder`.
    public var query: Connectable.Connection.Query {
        return .alterTable(alterTable)
    }
    
    /// See `SQLColumnBuilder`.
    public var columns: [Connectable.Connection.Query.AlterTable.ColumnDefinition] {
        get { return alterTable.columns }
        set { alterTable.columns = newValue }
    }

    /// Creates a new `SQLAlterTableBuilder`.
    ///
    /// - parameters:
    ///     - alterTable: Alter table query.
    ///     - connection: Connection to perform query on.
    public init(_ alterTable: Connectable.Connection.Query.AlterTable, on connectable: Connectable) {
        self.alterTable = alterTable
        self.connectable = connectable
    }
}

// MARK: Connection

extension SQLConnectable {
    /// Creates a new `SQLAlterTableBuilder`.
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
