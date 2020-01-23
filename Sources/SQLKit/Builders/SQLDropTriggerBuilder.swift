/// Builds `SQLDropTrigger` query
///
///   conn.drop()
///
/// See `SQLQueryBuilder` for more information.
public final class SQLDropTriggerBuilder: SQLQueryBuilder {
    /// `SQLDropTrigger` query being built.
    public var dropTrigger: SQLDropTrigger

    /// See `SQLQueryBuilder`.
    public var database: SQLDatabase

    /// See `SQLQueryBuilder`.
    public var query: SQLExpression {
        return self.dropTrigger
    }

    public init(_ dropTrigger: SQLDropTrigger, on database: SQLDatabase) {
        self.dropTrigger = dropTrigger
        self.database = database
    }

    /// The optional `IF EXISTS` clause suppresses the error that would normally
    /// result if the table does not exist.
    public func ifExists() -> Self {
        dropTrigger.ifExists = true
        return self 
    }

    /// The optional `CASCADE` clause drops other objects that depend on this type
    /// (such as table columns, functions, and operators), and in turn all objects
    /// that depend on those objects.
    public func cascade() -> Self {
        dropTrigger.cascade = true
        return self
    }
}

// MARK: Connection

extension SQLDatabase {
    public func drop(trigger: String, table: String) -> SQLDropTriggerBuilder {
        return self.drop(trigger: SQLIdentifier(trigger), table: SQLIdentifier(table))
    }

    public func drop(trigger: SQLExpression, table: SQLExpression) -> SQLDropTriggerBuilder {
        return .init(.init(name: trigger, table: table), on: self)
    }
}
