/// Builds raw SQL queries.
///
///     conn.raw("SELECT * FROM planets WHERE name = ?")
///         .bind("Earth")
///         .all(decoding: Planet.self)
///
public final class SQLRawBuilder<Connectable>: SQLQueryBuilder, SQLQueryFetcher
    where Connectable: SQLConnectable
{
    /// Raw query being built.
    public var sql: String
    
    /// Bound values.
    public var binds: [Encodable]
    
    /// See `SQLQueryBuilder`.
    public var connectable: Connectable
    
    /// See `SQLQueryBuilder`.
    public var query: Connectable.Connection.Query {
        return .raw(sql, binds: binds)
    }
    
    /// Creates a new `SQLRawBuilder`.
    public init(_ sql: String, on connectable: Connectable) {
        self.sql = sql
        self.connectable = connectable
        self.binds = []
    }
    
    /// Binds a single encodable value to the query. Each bind should
    /// correspond to a placeholder in the query string.
    ///
    ///     conn.raw("SELECT * FROM planets WHERE name = ?")
    ///         .bind("Earth")
    ///         .all(decoding: Planet.self)
    ///
    /// This method can be chained multiple times.
    public func bind(_ encodable: Encodable) -> Self {
        self.binds.append(encodable)
        return self
    }
    
    /// Binds an array of encodable values to the query. Each item in the
    /// array should correspond to a placeholder in the query string.
    ///
    ///     conn.raw("SELECT * FROM planets WHERE name = ? OR name = ?")
    ///         .binds(["Earth", "Mars"])
    ///         .all(decoding: Planet.self)
    ///
    /// This method can be chained multiple times.
    public func binds(_ encodables: [Encodable]) -> Self {
        self.binds += encodables
        return self
    }
}

// MARK: Connection

extension SQLConnectable {
    /// Creates a new `SQLRawBuilder`.
    ///
    ///     conn.raw("SELECT * FROM ...")...
    ///
    /// - parameters:
    ///     - table: Table to alter.
    /// - returns: `SQLRawBuilder`.
    public func raw(_ sql: String) -> SQLRawBuilder<Self> {
        return .init(sql, on: self)
    }
}
