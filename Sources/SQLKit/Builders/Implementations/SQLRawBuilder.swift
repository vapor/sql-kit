/// Builds raw SQL queries.
public final class SQLRawBuilder: SQLQueryBuilder, SQLQueryFetcher {
    /// Raw query being built.
    @usableFromInline
    var sql: SQLQueryString

    // See `SQLQueryBuilder.database`.
    public var database: any SQLDatabase

    // See `SQLQueryBuilder.query`.
    @inlinable
    public var query: any SQLExpression {
        self.sql
    }

    /// Create a new ``SQLRawBuilder``.
    @inlinable
    public init(_ sql: SQLQueryString, on database: any SQLDatabase) {
        self.database = database
        self.sql = sql
    }
}

extension SQLDatabase {
    /// Create a new ``SQLRawBuilder``.
    @inlinable
    public func raw(_ sql: SQLQueryString) -> SQLRawBuilder {
        .init(sql, on: self)
    }
}
