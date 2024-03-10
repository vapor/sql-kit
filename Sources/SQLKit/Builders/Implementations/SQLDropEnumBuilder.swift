/// Builds ``SQLDropEnum`` queries.
public final class SQLDropEnumBuilder: SQLQueryBuilder {
    /// ``SQLDropEnum`` query being built.
    public var dropEnum: SQLDropEnum

    // See `SQLQueryBuilder.database`.
    public var database: any SQLDatabase

    // See `SQLQueryBuilder.query`.
    @inlinable
    public var query: any SQLExpression {
        self.dropEnum
    }

    /// Create a new ``SQLDropEnumBuilder``.
    @usableFromInline
    init(name: any SQLExpression, on database: any SQLDatabase) {
        self.dropEnum = .init(name: name)
        self.database = database
    }

    /// The optional `IF EXISTS` clause suppresses the error that would normally
    /// result if the type does not exist.
    @inlinable
    @discardableResult
    public func ifExists() -> Self {
        self.dropEnum.ifExists = true
        return self
    }

    /// The drop behavior clause specifies if objects that depend on a type
    /// should also be dropped or not when the type is dropped, for databases
    /// that support this.
    @inlinable
    @discardableResult
    public func behavior(_ behavior: SQLDropBehavior) -> Self {
        self.dropEnum.dropBehavior = behavior
        return self
    }

    /// Adds a `CASCADE` clause to the `DROP TYPE` statement instructing that
    /// objects that depend on this type should also be dropped.
    @inlinable
    @discardableResult
    public func cascade() -> Self {
        self.behavior(.cascade)
    }

    /// Adds a `RESTRICT` clause to the `DROP TYPE` statement instructing that
    /// if any objects depend on this type, the drop should be refused.
    @inlinable
    @discardableResult
    public func restrict() -> Self {
        self.behavior(.restrict)
    }
}

extension SQLDatabase {
    /// Create a new ``SQLDropEnumBuilder``.
    @inlinable
    public func drop(enum name: String) -> SQLDropEnumBuilder {
        self.drop(enum: SQLIdentifier(name))
    }

    /// Create a new ``SQLDropEnumBuilder``.
    @inlinable
    public func drop(enum name: any SQLExpression) -> SQLDropEnumBuilder {
        .init(name: name, on: self)
    }
}
