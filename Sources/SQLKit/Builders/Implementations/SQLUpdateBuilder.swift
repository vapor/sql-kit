/// Builds ``SQLUpdate`` queries.
///
/// ```swift
/// try await db.update("planets")
///     .set("name", to: "Earth")
///     .where("name", .equal, "Earth")
///     .run()
/// ```
public final class SQLUpdateBuilder: SQLQueryBuilder, SQLPredicateBuilder, SQLReturningBuilder, SQLColumnUpdateBuilder {
    /// An ``SQLUpdate`` containing the complete current state of the builder.
    public var update: SQLUpdate
    
    // See `SQLQueryBuilder.database`.
    public var database: any SQLDatabase

    // See `SQLQueryBuilder.query`.
    @inlinable
    public var query: any SQLExpression {
        self.update
    }
    
    // See `SQLColumnUpdateBuilder.values`.
    @inlinable
    public var values: [any SQLExpression] {
        get { self.update.values }
        set { self.update.values = newValue }
    }

    // See `SQLPredicateBuilder.predicate`.
    @inlinable
    public var predicate: (any SQLExpression)? {
        get { self.update.predicate }
        set { self.update.predicate = newValue }
    }

    // See `SQLReturningBuilder.returning`.
    @inlinable
    public var returning: SQLReturning? {
        get { self.update.returning }
        set { self.update.returning = newValue }
    }
    
    /// Create a new ``SQLUpdateBuilder``.
    ///
    /// Use this API directly only if you need to have control over the builder's initial update query. Prefer using
    /// ``SQLDatabase/update(_:)-42k7h`` or ``SQLDatabase/update(_:)-2fl0d`` whnever possible.
    ///
    /// - Parameters:
    ///   - update: A query to use as the builder's initial state. It must at minimum specify a table to update.
    ///   - database: A database to associate with the builder.
    @inlinable
    public init(_ update: SQLUpdate, on database: any SQLDatabase) {
        self.update = update
        self.database = database
    }
}

extension SQLDatabase {
    public func update(_ table: String) -> SQLUpdateBuilder {
    /// Create a new ``SQLUpdateBuilder`` associated with this database.
    /// 
    /// - Parameter table: A table to specify for the builder's update query.
    /// - Returns: A new builder.
        self.update(SQLIdentifier(table))
    }
    
    public func update(_ table: any SQLExpression) -> SQLUpdateBuilder {
    /// Create a new ``SQLUpdateBuilder`` associated with this database.
    ///
    /// - Parameter table: An expression used as the target of the builder's update query.
    /// - Returns: A new builder. 
        .init(.init(table: table), on: self)
    }
}
