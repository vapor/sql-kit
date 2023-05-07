/// Builds ``SQLDropTrigger`` queries.
public final class SQLDropTriggerBuilder: SQLQueryBuilder {
    /// ``SQLDropTrigger`` query being built.
    public var dropTrigger: SQLDropTrigger

    /// See ``SQLQueryBuilder/database``.
    public var database: any SQLDatabase

    /// See ``SQLQueryBuilder/query``.
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

    /// The optional `CASCADE` clause drops other objects that depend on this type
    /// (such as table columns, functions, and operators), and in turn all objects
    /// that depend on those objects.
    @inlinable
    @discardableResult
    public func cascade() -> Self {
        self.dropTrigger.cascade = true
        return self
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
