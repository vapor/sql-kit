/// Builds `SQLDropTable` queries.
///
///     conn.drop(table: Planet.self).run()
///
/// See `SQLQueryBuilder` for more information.
public final class SQLDropTableBuilder: SQLQueryBuilder {
    /// `DropTable` query being built.
    public var dropTable: SQLDropTable
    
    /// See `SQLQueryBuilder`.
    public var database: SQLDatabase
    
    /// See `SQLQueryBuilder`.
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
    public func ifExists() -> Self {
        dropTable.ifExists = true
        return self
    }
}

// MARK: Connection

extension SQLDatabase {
    /// Creates a new `SQLDropTable` builder.
    ///
    ///     conn.drop(table: "planets").run()
    ///
    public func drop(table: String) -> SQLDropTableBuilder {
        return self.drop(table: SQLIdentifier(table))
    }
    
    /// Creates a new `SQLDropTable` builder.
    ///
    ///     conn.drop(table: "planets").run()
    ///
    public func drop(table: SQLExpression) -> SQLDropTableBuilder {
        return .init(.init(table: table), on: self)
    }
}
