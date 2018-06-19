public final class SQLRawBuilder<Connection>: SQLQueryBuilder, SQLQueryFetcher
    where Connection: DatabaseQueryable, Connection.Query: SQLQuery
{
    /// Raw query being built.
    public var sql: String
    
    public var binds: [Encodable]
    
    /// See `SQLQueryBuilder`.
    public var connection: Connection
    
    /// See `SQLQueryBuilder`.
    public var query: Connection.Query {
        return .raw(sql, binds: binds)
    }
    
    /// Creates a new `SQLAlterTableBuilder`.
    public init(_ sql: String, on connection: Connection) {
        self.sql = sql
        self.connection = connection
        self.binds = []
    }
    
    public func bind(_ encodable: Encodable) -> Self {
        self.binds.append(encodable)
        return self
    }
    
    public func binds(_ encodables: [Encodable]) -> Self {
        self.binds += encodables
        return self
    }
}

// MARK: Connection

extension DatabaseQueryable where Query: SQLQuery {
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
