/// Builds `ALTER TABLE` queries.
///
///     conn.alter(table: Planet.self)
///         .column(for: \.name)
///         .run()
///
/// See `SQLColumnBuilder` for more information.
public final class SQLAlterTableBuilder<Database>: SQLQueryBuilder, SQLColumnBuilder
    where Database: SQLDatabase
{
    /// See `SQLColumnBuilder`.
    public typealias ColumnDefinition = Database.Query.AlterTable.ColumnDefinition
    
    /// `SQLAlterTable` query being built.
    public var alterTable: Database.Query.AlterTable

    /// See `SQLQueryBuilder`.
    public var database: Database

    /// See `SQLQueryBuilder`.
    public var query: Database.Query {
        return .alterTable(alterTable)
    }
    
    /// See `SQLColumnBuilder`.
    public var columns: [Database.Query.AlterTable.ColumnDefinition] {
        get { return alterTable.columns }
        set { alterTable.columns = newValue }
    }

    /// Creates a new `SQLAlterTableBuilder`.
    ///
    /// - parameters:
    ///     - alterTable: Alter table query.
    ///     - connection: Connection to perform query on.
    public init(_ alterTable: Database.Query.AlterTable, on database: Database) {
        self.alterTable = alterTable
        self.database = database
    }
}

// MARK: Connection

extension SQLDatabase {
    /// Creates a new `SQLAlterTableBuilder`.
    ///
    ///     conn.alter(table: Planet.self)...
    ///
    /// - parameters:
    ///     - table: Table to alter.
    /// - returns: `AlterTableBuilder`.
    public func alter(table: Query.AlterTable.TableIdentifier) -> SQLAlterTableBuilder<Self> {
        return .init(.alterTable(table), on: self)
    }
}
