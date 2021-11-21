/// Builds `SQLDropTable` queries.
///
///     db.drop(table: Planet.self).run()
///
/// See `SQLQueryBuilder` for more information.
public final class SQLDropTableBuilder: SQLQueryBuilder {
    /// `DropTable` query being built.
    public var dropTable: SQLDropTable
    
    // See `SQLQueryBuilder.database`.
    public var database: SQLDatabase
    
    // See `SQLQueryBuilder.query`.
    public var query: SQLExpression {
        return self.dropTable
    }
    
    /// Creates a new `SQLDropTableBuilder`.
    public init(_ dropTable: SQLDropTable, on database: SQLDatabase) {
        self.dropTable = dropTable
        self.database = database
    }
    
    /// The optional `IF EXISTS` clause suppresses the error that would normally
    /// result if the table does not exist.
    @discardableResult
    public func ifExists() -> Self {
        dropTable.ifExists = true
        return self
    }

    /// The drop behavior clause specifies if objects that depend on a table
    /// should also be dropped or not when the table is dropped, for databases
    /// that support this.
    @discardableResult
    public func behavior(_ behavior: SQLDropBehavior) -> Self {
        dropTable.behavior = behavior
        return self
    }

    /// Adds a `CASCADE` clause to the `DROP TABLE` statement instructing that
    /// objects that depend on this table should also be dropped.
    @discardableResult
    public func cascade() -> Self {
        dropTable.behavior = SQLDropBehavior.cascade
        return self
    }

    /// Adds a `RESTRICT` clause to the `DROP TABLE` statement instructing that
    /// if any objects depend on this table, the drop should be refused.
    @discardableResult
    public func restrict() -> Self {
        dropTable.behavior = SQLDropBehavior.restrict
        return self
    }

    /// If the "TEMPORARY" keyword occurs between "DROP" and "TABLE" then only temporary tables are dropped,
    /// and the drop does not cause an implicit transaction commit.
    @discardableResult
    public func temporary() -> Self {
        dropTable.temporary = true
        return self
    }
}

// MARK: Connection

extension SQLDatabase {
    /// Creates a new `SQLDropTable` builder.
    ///
    ///     db.drop(table: "planets").run()
    ///
    public func drop(table: String) -> SQLDropTableBuilder {
        return self.drop(table: SQLIdentifier(table))
    }
    
    /// Creates a new `SQLDropTable` builder.
    ///
    ///     db.drop(table: "planets").run()
    ///
    public func drop(table: SQLExpression) -> SQLDropTableBuilder {
        return .init(.init(table: table), on: self)
    }
}
