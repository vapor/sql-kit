/// Builds `SQLUpdate` queries.
///
///     conn.update(Planet.self)
///         .set(\Planet.name == "Earth")
///         .where(\Planet.name == "Eatrh")
///         .run()
///
/// See `SQLQueryBuilder` and `SQLPredicateBuilder` for more information.
public final class SQLUpdateBuilder<Database>: SQLQueryBuilder, SQLPredicateBuilder
    where Database: SQLDatabase
{
    /// `Update` query being built.
    public var update: Database.Query.Update
    
    /// See `SQLQueryBuilder`.
    public var database: Database
    
    /// See `SQLQueryBuilder`.
    public var query: Database.Query {
        return .update(update)
    }
    
    /// See `SQLWhereBuilder`.
    public var predicate: Database.Query.Update.Expression? {
        get { return update.predicate }
        set { update.predicate = newValue }
    }
    
    /// Creates a new `SQLDeleteBuilder`.
    public init(_ update: Database.Query.Update, on database: Database) {
        self.update = update
        self.database = database
    }
    
    /// Adds an encodable model's properties to the `UPDATE` statement.
    ///
    ///     conn.update(Planet.self)
    ///         .set(earth)
    ///         .where(\Planet.id == earth.id)
    ///         .run()
    ///
    public func set<E>(_ model: E)-> Self
        where E: Encodable
    {
        for row in SQLQueryEncoder(Database.Query.Update.Expression.self).encode(model) {
            _ = set(.identifier(row.key), to: row.value)
        }
        return self
    }
    
    /// Sets a column (specified by key path) to an encodable value.
    ///
    ///     conn.update(Planet.self)
    ///         .set(\Planet.name == "Earth")
    ///         .where(\Planet.name == "Eatrh")
    ///         .run()
    ///
    public func set<T, V>(_ keyPath: KeyPath<T, V>, to value: V)  -> Self
        where T: SQLTable, V: Encodable
    {
        return set(.keyPath(keyPath), to: .bind(.encodable(value)))
    }
    
    /// Sets a column (specified by key path) to an expression.
    public func set<T, V>(_ keyPath: KeyPath<T, V>, to expression: Database.Query.Update.Expression) -> Self
        where T: SQLTable
    {
        return set(.keyPath(keyPath), to: expression)
    }
    
    /// Sets a column (specified by an identifier) to an expression.
    public func set(_ identifier: Database.Query.Update.Identifier, to expression: Database.Query.Update.Expression) -> Self {
        update.values.append((identifier, expression))
        return self
    }
}

// MARK: Connection

extension SQLDatabase {
    /// Creates a new `SQLUpdateBuilder`.
    ///
    ///     conn.update(Planet.self)...
    ///
    /// - parameters:
    ///     - table: Table to update.
    /// - returns: Newly created `SQLUpdateBuilder`.
    public func update(_ table: Query.Update.Identifier) -> SQLUpdateBuilder<Self> {
        return .init(.update(table: table), on: self)
    }
}
