/// Builds raw SQL queries.
public final class SQLUnsafeRawBuilder: SQLQueryBuilder, SQLQueryFetcher {
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

    /// Create a new ``SQLUnsafeRawBuilder``.
    @inlinable
    public init(_ sql: SQLQueryString, on database: any SQLDatabase) {
        self.database = database
        self.sql = sql
    }
}

extension SQLDatabase {
    /// Create a new ``SQLUnsafeRawBuilder``.
    @inlinable
    public func unsafeRaw(_ sql: SQLQueryString) -> SQLUnsafeRawBuilder {
        .init(sql, on: self)
    }
}
