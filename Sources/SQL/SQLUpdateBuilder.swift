public final class SQLUpdateBuilder<Connection>: SQLQueryBuilder, SQLPredicateBuilder
    where Connection: DatabaseQueryable, Connection.Query: SQLQuery
{
    /// `Update` query being built.
    public var update: Connection.Query.Update
    
    /// See `SQLQueryBuilder`.
    public var connection: Connection
    
    /// See `SQLQueryBuilder`.
    public var query: Connection.Query {
        return .update(update)
    }
    
    /// See `SQLWhereBuilder`.
    public var predicate: Connection.Query.Update.Expression? {
        get { return update.predicate }
        set { update.predicate = newValue }
    }
    
    /// Creates a new `SQLDeleteBuilder`.
    public init(_ update: Connection.Query.Update, on connection: Connection) {
        self.update = update
        self.connection = connection
    }
    
    public func set<E>(_ model: E)-> Self
        where E: Encodable
    {
        let row = SQLQueryEncoder(Connection.Query.Update.Expression.self).encode(model)
        update.values += row.map { row -> (Connection.Query.Update.Identifier, Connection.Query.Update.Expression) in
            return (.identifier(row.key), row.value)
        }
        return self
    }
    
    public func set<T, V>(_ keyPath: KeyPath<T, V>, to value: V)  -> Self
        where V: Encodable, T: SQLTable
    {
        update.values.append((.keyPath(keyPath), .bind(.encodable(value))))
        return self
    }
}

// MARK: Connection

extension DatabaseQueryable where Query: SQLQuery {
    /// Creates a new `SQLUpdateBuilder`.
    ///
    ///     conn.update(Planet.self)...
    ///
    /// - parameters:
    ///     - table: Table to update.
    /// - returns: Newly created `SQLUpdateBuilder`.
    public func update<Table>(_ table: Table.Type) -> SQLUpdateBuilder<Self>
        where Table: SQLTable
    {
        return .init(.update(.table(Table.self)), on: self)
    }
}
