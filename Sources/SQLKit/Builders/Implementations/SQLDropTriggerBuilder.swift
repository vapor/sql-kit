/// Builds ``SQLDropTrigger`` queries.
public final class SQLDropTriggerBuilder: SQLQueryBuilder {
    /// ``SQLDropTrigger`` query being built.
    public var dropTrigger: SQLDropTrigger

    // See `SQLQueryBuilder.database`.
    public var database: any SQLDatabase

    // See `SQLQueryBuilder.query`.
    @inlinable
    public var query: any SQLExpression {
        self.dropTrigger
    }

    /// Create a new ``SQLDropTableBuilder``.
    @inlinable
    public init(_ dropTrigger: SQLDropTrigger, on database: any SQLDatabase) {
        self.dropTrigger = dropTrigger
        self.database = database
    }

    /// The optional `IF EXISTS` clause suppresses the error that would normally
    /// result if the table does not exist.
    @inlinable
    @discardableResult
    public func ifExists() -> Self {
        self.dropTrigger.ifExists = true
        return self 
    }

    /// The drop behavior clause specifies if objects that depend on a trigger
    /// should also be dropped or not when the trigger is dropped, for databases
    /// that support this.
    @inlinable
    @discardableResult
    public func behavior(_ behavior: SQLDropBehavior) -> Self {
        self.dropTrigger.dropBehavior = behavior
        return self
    }

    /// Adds a `CASCADE` clause to the `DROP TRIGGER` statement instructing that
    /// objects that depend on this trigger should also be dropped.
    @inlinable
    @discardableResult
    public func cascade() -> Self {
        self.behavior(.cascade)
    }

    /// Adds a `RESTRICT` clause to the `DROP TRIGGER` statement instructing that
    /// if any objects depend on this trigger, the drop should be refused.
    @inlinable
    @discardableResult
    public func restrict() -> Self {
        self.behavior(.restrict)
    }

    /// Specify an associated table that owns the trigger to drop, for dialects that require it.
    @inlinable
    @discardableResult
    public func table(_ name: String) -> Self {
        self.table(SQLIdentifier(name))
    }
    
    /// Specify an associated table that owns the trigger to drop, for dialects that require it.
    @inlinable
    @discardableResult
    public func table(_ name: any SQLExpression) -> Self {
        self.dropTrigger.table = name
        return self
    }
}

extension SQLDatabase {
    /// Create a new ``SQLDropTableBuilder``.
    @inlinable
    public func drop(trigger: String) -> SQLDropTriggerBuilder {
        self.drop(trigger: SQLIdentifier(trigger))
    }

    /// Create a new ``SQLDropTableBuilder``.
    @inlinable
    public func drop(trigger: any SQLExpression) -> SQLDropTriggerBuilder {
        .init(.init(name: trigger), on: self)
    }
}
