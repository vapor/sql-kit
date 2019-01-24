/// Builds `SQLInsert` queries.
///
///     conn.insert(into: "planets"")
///         .value(earth).run()
///
/// See `SQLQueryBuilder` for more information.
public final class SQLInsertBuilder: SQLQueryBuilder {
    /// `Insert` query being built.
    public var insert: SQLInsert
    
    /// See `SQLQueryBuilder`.
    public var database: SQLDatabase
    
    /// See `SQLQueryBuilder`.
    public var query: SQLExpression {
        return self.insert
    }
    
    /// Creates a new `SQLInsertBuilder`.
    public init(_ insert: SQLInsert, on database: SQLDatabase) {
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
        fatalError()
//        values.forEach { model in
//            let row = SQLQueryEncoder(Database.Query.Insert.Expression.self).encode(model)
//            if insert.columns.isEmpty {
//                insert.columns += row.map { .column(name: .identifier($0.key), table: nil) }
//            } else {
//                assert(
//                    insert.columns.count == row.count,
//                    "Column count (\(insert.columns.count)) did not equal value count (\(row.count)): \(model)."
//                )
//            }
//            insert.values.append(row.map { row in
//                if row.value.isNull {
//                    return .literal(.default)
//                } else {
//                    return row.value
//                }
//            })
//        }
//        return self
    }
    
    public func columns(_ columns: String...) -> Self {
        self.insert.columns = columns.map(SQLIdentifier.init)
        return self
    }
    
    public func columns(_ columns: SQLExpression...) -> Self {
        self.insert.columns = columns
        return self
    }
    
    public func values(_ values: Encodable...) -> Self {
        self.insert.values.append(values.map(SQLBind.init))
        return self
    }
    
    public func values(_ values: SQLExpression...) -> Self {
        self.insert.values.append(values)
        return self
    }
}

// MARK: Connection

extension SQLDatabase {
    /// Creates a new `SQLInsertBuilder`.
    ///
    ///     conn.insert(into: "planets")...
    ///
    /// - parameters:
    ///     - table: Table to insert into.
    /// - returns: Newly created `SQLInsertBuilder`.
    public func insert(into table: String) -> SQLInsertBuilder {
        return self.insert(into: SQLIdentifier(table))
    }
    
    /// Creates a new `SQLInsertBuilder`.
    ///
    ///     conn.insert(into: "planets")...
    ///
    /// - parameters:
    ///     - table: Table to insert into.
    /// - returns: Newly created `SQLInsertBuilder`.
    public func insert(into table: SQLExpression) -> SQLInsertBuilder {
        return .init(.init(table: table), on: self)
    }
}
