/// Builds ``SQLUpdate`` queries.
///
///     db.update(Planet.schema)
///         .set("name", to: "Earth")
///         .where("name", .equal, "Earth")
///         .run()
public final class SQLUpdateBuilder: SQLQueryBuilder, SQLPredicateBuilder, SQLReturningBuilder, SQLColumnUpdateBuilder {
    /// ``SQLUpdate`` query being built.
    public var update: SQLUpdate
    
    /// See ``SQLQueryBuilder/database``.
    public var database: any SQLDatabase

    /// See ``SQLQueryBuilder/query``.
    @inlinable
    public var query: any SQLExpression {
        self.update
    }
    
    /// See ``SQLColumnUpdateBuilder/values``.
    @inlinable
    public var values: [any SQLExpression] {
        get { self.update.values }
        set { self.update.values = newValue }
    }

    /// See ``SQLPredicateBuilder/predicate``.
    @inlinable
    public var predicate: (any SQLExpression)? {
        get { self.update.predicate }
        set { self.update.predicate = newValue }
    }

    /// See ``SQLReturningBuilder/returning``.
    @inlinable
    public var returning: SQLReturning? {
        get { self.update.returning }
        set { self.update.returning = newValue }
    }
    
    /// Create a new ``SQLUpdateBuilder``.
    @inlinable
    public init(_ update: SQLUpdate, on database: any SQLDatabase) {
        self.update = update
        self.database = database
    }
}

extension SQLDatabase {
    /// Create a new ``SQLUpdateBuilder``.
    public func update(_ table: String) -> SQLUpdateBuilder {
        self.update(SQLIdentifier(table))
    }
    
    /// Create a new ``SQLUpdateBuilder``.
    public func update(_ table: any SQLExpression) -> SQLUpdateBuilder {
        .init(.init(table: table), on: self)
    }
}
