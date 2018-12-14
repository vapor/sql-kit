/// Builds `SQLInsert` queries.
///
///     conn.insert(into: Planet.self)
///         .value(earth).run()
///
/// See `SQLQueryBuilder` for more information.
public final class SQLInsertBuilder<Database>: SQLQueryBuilder
    where Database: SQLDatabase
{
    /// `Insert` query being built.
    public var insert: Database.Query.Insert
    
    /// See `SQLQueryBuilder`.
    public var database: Database
    
    /// See `SQLQueryBuilder`.
    public var query: Database.Query {
        return .insert(insert)
    }
    
    /// Creates a new `SQLInsertBuilder`.
    public init(_ insert: Database.Query.Insert, on database: Database) {
        self.insert = insert
        self.database = database
    }
    
    /// Adds a single encodable value to be inserted. Equivalent to calling `values(_:)`
    /// with single-element array.
    ///
    ///     conn.insert(into: Planet.self)
    ///         .value(earth).run()
    ///
    /// - parameters:
    ///     - value: `Encodable` value to insert.
    /// - returns: Self for chaining.
    public func value<E>(_ value: E) throws -> Self
        where E: Encodable
    {
        return values([value])
    }
    
    /// Adds zero or more encodable values to be inserted. The columns will be determined by the
    /// first value inserted. All subsequent values must have equal column count.
    ///
    ///     conn.insert(into: Planet.self)
    ///         .values([earth, mars]).run()
    ///
    /// - parameters:
    ///     - values: Array of `Encodable` values to insert.
    /// - returns: Self for chaining.
    public func values<E>(_ values: [E]) -> Self
        where E: Encodable
    {
        values.forEach { model in
            let row = SQLQueryEncoder(Database.Query.Insert.Expression.self).encode(model)
            if insert.columns.isEmpty {
                insert.columns += row.map { .column(name: .identifier($0.key), table: nil) }
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
}

// MARK: Connection

extension SQLDatabase {
    /// Creates a new `SQLInsertBuilder`.
    ///
    ///     conn.insert(into: Planet.self)...
    ///
    /// - parameters:
    ///     - table: Table to insert into.
    /// - returns: Newly created `SQLInsertBuilder`.
    public func insert(into table: Query.Identifier) -> SQLInsertBuilder<Self> {
        return .init(.insert(table: table), on: self)
    }
}
