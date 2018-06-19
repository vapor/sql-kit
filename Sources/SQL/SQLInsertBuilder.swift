public final class SQLInsertBuilder<Connection>: SQLQueryBuilder
    where Connection: DatabaseQueryable, Connection.Query: SQLQuery
{
    /// `Insert` query being built.
    public var insert: Connection.Query.Insert
    
    /// See `SQLQueryBuilder`.
    public var connection: Connection
    
    /// See `SQLQueryBuilder`.
    public var query: Connection.Query {
        return .insert(insert)
    }
    
    /// Creates a new `SQLInsertBuilder`.
    public init(_ insert: Connection.Query.Insert, on connection: Connection) {
        self.insert = insert
        self.connection = connection
    }
    
    public func value<E>(_ value: E) throws -> Self
        where E: Encodable
    {
        return values([value])
    }
    
    public func values<E>(_ values: [E]) -> Self
        where E: Encodable
    {
        values.forEach { model in
            let row = SQLQueryEncoder(Connection.Query.Insert.Expression.self).encode(model)
            if insert.columns.isEmpty {
                insert.columns += row.map { .column(nil, .identifier($0.key)) }
            } else {
                assert(
                    insert.columns.count == row.count,
                    "Column count (\(insert.columns.count)) did not equal value count (\(row.count)): \(model)."
                )
            }
            insert.values.append(row.map { row in
                if row.value.isNull {
                    return .literal(.default)
                } else {
                    return row.value
                }
            })
        }
        return self
    }
    
    public func onConflict<E>(set value: E) -> Self where E: Encodable {
        let row = SQLQueryEncoder(Connection.Query.Insert.Upsert.Expression.self).encode(value)
        let values = row.map { row -> (Connection.Query.Insert.Upsert.Identifier, Connection.Query.Insert.Upsert.Expression) in
            return (.identifier(row.key), row.value)
        }
        insert.upsert = .upsert(values)
        return self
    }
}

// MARK: Connection

extension DatabaseQueryable where Query: SQLQuery {
    /// Creates a new `SQLInsertBuilder`.
    ///
    ///     conn.insert(into: Planet.self)...
    ///
    /// - parameters:
    ///     - table: Table to insert into.
    /// - returns: Newly created `SQLInsertBuilder`.
    public func insert<Table>(into table: Table.Type) -> SQLInsertBuilder<Self>
        where Table: SQLTable
    {
        return .init(.insert(.table(Table.self)), on: self)
    }
}
