/// Builds `ALTER TABLE` queries.
///
///     conn.alter(table: Planet.self)
///         .column(for: \.name)
///         .run()
///
/// See `SQLColumnBuilder` for more information.
public final class SQLAlterTableBuilder: SQLQueryBuilder, SQLColumnBuilder {
    /// `SQLAlterTable` query being built.
    public var alterTable: SQLAlterTable

    /// See `SQLQueryBuilder`.
    public var database: SQLDatabase

    /// See `SQLQueryBuilder`.
    public var query: SQLExpression {
        return self.alterTable
    }
    
    /// See `SQLColumnBuilder`.
    public var columns: [SQLExpression] {
        get { return alterTable.columns }
        set { alterTable.columns = newValue }
    }

    /// Creates a new `SQLAlterTableBuilder`.
    ///
    /// - parameters:
    ///     - alterTable: Alter table query.
    ///     - connection: Connection to perform query on.
    public init(_ alterTable: SQLAlterTable, on database: SQLDatabase) {
        self.alterTable = alterTable
        self.database = database
    }
}

// MARK: Connection

extension SQLDatabase {
    /// Creates a new `SQLAlterTableBuilder`.
    ///
    ///     conn.alter(table: "planets")...
    ///
    /// - parameters:
    ///     - table: Table to alter.
    /// - returns: `AlterTableBuilder`.
    public func alter(table: String) -> SQLAlterTableBuilder {
        return self.alter(table: SQLIdentifier(table))
    }
    
    /// Creates a new `SQLAlterTableBuilder`.
    ///
    /// - parameters:
    ///     - table: Table to alter.
    /// - returns: `AlterTableBuilder`.
    public func alter(table: SQLIdentifier) -> SQLAlterTableBuilder {
        return .init(.init(name: table), on: self)
    }
}
