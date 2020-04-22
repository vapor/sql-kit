/// Builds raw SQL queries.
///
///     db.raw("SELECT * FROM planets WHERE name = \(bind: "Earth")")
///         .all(decoding: Planet.self)
///
public final class SQLRawBuilder: SQLQueryBuilder, SQLQueryFetcher {
    /// Raw query being built.
    var sql: SQLQueryString

    /// See `SQLQueryBuilder`.
    public var database: SQLDatabase

    /// See `SQLQueryBuilder`.
    public var query: SQLExpression {
        return self.sql
    }

    /// Creates a new `SQLRawBuilder`.
    public init(_ sql: SQLQueryString, on database: SQLDatabase) {
        self.database = database
        self.sql = sql
    }
}

// MARK: Connection

extension SQLDatabase {
    /// Creates a new `SQLRawBuilder`.
    ///
    ///     db.raw("SELECT * FROM ...")...
    ///
    /// - parameters:
    ///     - sql: The SQL query string.
    /// - returns: `SQLRawBuilder`.
    public func raw(_ sql: SQLQueryString) -> SQLRawBuilder {
        return .init(sql, on: self)
    }
}
