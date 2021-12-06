/// Builds `SQLUpdate` queries.
///
///     db.update(Planet.self)
///         .set(\Planet.name == "Earth")
///         .where(\Planet.name == "Eatrh")
///         .run()
///
/// See `SQLQueryBuilder` and `SQLPredicateBuilder` for more information.
public final class SQLUpdateBuilder: SQLQueryBuilder, SQLPredicateBuilder, SQLReturningBuilder, SQLColumnUpdateBuilder {
    /// `Update` query being built.
    public var update: SQLUpdate
    
    public var database: SQLDatabase

    public var query: SQLExpression {
        return self.update
    }
    
    public var values: [SQLExpression] {
        get { return self.update.values }
        set { self.update.values = newValue }
    }

    public var predicate: SQLExpression? {
        get { return self.update.predicate }
        set { self.update.predicate = newValue }
    }

    public var returning: SQLReturning? {
        get { return self.update.returning }
        set { self.update.returning = newValue }
    }
    
    /// Creates a new `SQLUpdateBuilder`.
    public init(_ update: SQLUpdate, on database: SQLDatabase) {
        self.update = update
        self.database = database
    }
}

// MARK: Connection

extension SQLDatabase {
    /// Creates a new `SQLUpdateBuilder`.
    ///
    ///     db.update("planets")...
    ///
    /// - parameters:
    ///     - table: Table to update.
    /// - returns: Newly created `SQLUpdateBuilder`.
    public func update(_ table: String) -> SQLUpdateBuilder {
        return self.update(SQLIdentifier(table))
    }
    
    /// Creates a new `SQLUpdateBuilder`.
    ///
    ///     db.update("planets")...
    ///
    /// - parameters:
    ///     - table: Table to update.
    /// - returns: Newly created `SQLUpdateBuilder`.
    public func update(_ table: SQLExpression) -> SQLUpdateBuilder {
        return .init(.init(table: table), on: self)
    }
}
