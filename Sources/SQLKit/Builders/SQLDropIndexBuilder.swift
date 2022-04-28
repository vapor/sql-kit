/// Builds `SQLDropIndex` queries.
///
///     db.drop(index: "planet_name_unique").run()
///
/// See `SQLDropIndex`.
public final class SQLDropIndexBuilder: SQLQueryBuilder {
    /// `DropIndex` query being built.
    public var dropIndex: SQLDropIndex
    
    /// See `SQLQueryBuilder`.
    public var database: SQLDatabase
    
    /// See `SQLQueryBuilder`.
    public var query: SQLExpression {
        return self.dropIndex
    }
    
    /// Creates a new `SQLDropIndexBuilder`.
    public init(_ dropIndex: SQLDropIndex, on database: SQLDatabase) {
        self.dropIndex = dropIndex
        self.database = database
    }

    /// The optional `IF EXISTS` clause suppresses the error that would normally
    /// result if the index does not exist.
    @discardableResult
    public func ifExists() -> Self {
        dropIndex.ifExists = true
        return self
    }
    
    /// Convenience method for specifying an owning object using a `String`. See
    /// ``on(_:)-84xo2`` for details.
    @discardableResult
    public func on(_ owningObject: String) -> Self {
        return self.on(SQLIdentifier(owningObject))
    }

    /// The object (usually a table) which owns the index may be explicitly specified.
    /// Some dialects treat indexes as database-level objects in their own right and
    /// treat specifying an owner as an error, while others require the owning object
    /// in order to perform the drop operation at all. At the time of this writing,
    /// there is no support for specifying this in `SQLDialect`; callers must ensure
    /// that they either specify or omit an owning object as appropriate.
    @discardableResult
    public func on(_ owningObject: SQLExpression) -> Self {
        dropIndex.owningObject = owningObject
        return self
    }

    /// The drop behavior clause specifies if objects that depend on a index
    /// should also be dropped or not when the index is dropped, for databases
    /// that support this.
    @discardableResult
    public func behavior(_ behavior: SQLDropBehavior) -> Self {
        dropIndex.behavior = behavior
        return self
    }

    /// Adds a `CASCADE` clause to the `DROP INDEX` statement instructing that
    /// objects that depend on this index should also be dropped.
    @discardableResult
    public func cascade() -> Self {
        dropIndex.behavior = SQLDropBehavior.cascade
        return self
    }

    /// Adds a `RESTRICT` clause to the `DROP INDEX` statement instructing that
    /// if any objects depend on this index, the drop should be refused.
    @discardableResult
    public func restrict() -> Self {
        dropIndex.behavior = SQLDropBehavior.restrict
        return self
    }
}

// MARK: Connection

extension SQLDatabase {
    /// Creates a new `SQLDropIndexBuilder`.
    ///
    ///     db.drop(index: "foo").run()
    ///
    public func drop(index name: String) -> SQLDropIndexBuilder {
        return self.drop(index: SQLIdentifier(name))
    }
    
    /// Creates a new `SQLDropIndexBuilder`.
    ///
    ///     db.drop(index: "foo").run()
    ///
    public func drop(index name: SQLExpression) -> SQLDropIndexBuilder {
        return .init(.init(name: name), on: self)
    }
}
