/// Builds ``SQLDropTable`` queries.
public final class SQLDropTableBuilder: SQLQueryBuilder {
    /// ``SQLDropTable`` query being built.
    public var dropTable: SQLDropTable
    
    /// See ``SQLQueryBuilder/database``.
    public var database: any SQLDatabase
    
    /// See ``SQLQueryBuilder/query``.
    @inlinable
    public var query: any SQLExpression {
        self.dropTable
    }
    
    /// Create a new ``SQLDropTableBuilder``.
    @inlinable
    public init(_ dropTable: SQLDropTable, on database: any SQLDatabase) {
        self.dropTable = dropTable
        self.database = database
    }
    
    /// The optional `IF EXISTS` clause suppresses the error that would normally
    /// result if the table does not exist.
    @inlinable
    @discardableResult
    public func ifExists() -> Self {
        self.dropTable.ifExists = true
        return self
    }

    /// The drop behavior clause specifies if objects that depend on a table
    /// should also be dropped or not when the table is dropped, for databases
    /// that support this.
    @inlinable
    @discardableResult
    public func behavior(_ behavior: SQLDropBehavior) -> Self {
        self.dropTable.behavior = behavior
        return self
    }

    /// Adds a `CASCADE` clause to the `DROP TABLE` statement instructing that
    /// objects that depend on this table should also be dropped.
    @inlinable
    @discardableResult
    public func cascade() -> Self {
        self.dropTable.behavior = SQLDropBehavior.cascade
        return self
    }

    /// Adds a `RESTRICT` clause to the `DROP TABLE` statement instructing that
    /// if any objects depend on this table, the drop should be refused.
    @inlinable
    @discardableResult
    public func restrict() -> Self {
        self.dropTable.behavior = SQLDropBehavior.restrict
        return self
    }

    /// If the `TEMPORARY` keyword occurs between `DROP` and `TABLE`, then only
    /// temporary tables are dropped, and the drop does not cause an implicit transaction commit.
    @inlinable
    @discardableResult
    public func temporary() -> Self {
        self.dropTable.temporary = true
        return self
    }
}

extension SQLDatabase {
    /// Create a new ``SQLDropTableBuilder``.
    @inlinable
    public func drop(table: String) -> SQLDropTableBuilder {
        self.drop(table: SQLIdentifier(table))
    }
    
    /// Create a new ``SQLDropTableBuilder``.
    @inlinable
    public func drop(table: any SQLExpression) -> SQLDropTableBuilder {
        .init(.init(table: table), on: self)
    }
}
