/// Builds raw SQL queries.
///
///     conn.raw("SELECT * FROM planets WHERE name = ?")
///         .bind("Earth")
///         .all(decoding: Planet.self)
///
public final class SQLRawBuilder<Connection>: SQLQueryBuilder, SQLQueryFetcher
    where Connection: SQLConnection
{
    /// Raw query being built.
    public var sql: String
    
    /// Bound values.
    public var binds: [Encodable]
    
    /// See `SQLQueryBuilder`.
    public var connection: Connection
    
    /// See `SQLQueryBuilder`.
    public var query: Connection.Query {
        return .raw(sql, binds: binds)
    }
    
    /// Creates a new `SQLRawBuilder`.
    public init(_ sql: String, on connection: Connection) {
        self.sql = sql
        self.connection = connection
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

extension SQLConnection {
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
