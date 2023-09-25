/// Builds raw SQL queries.
///
///     db.raw("SELECT \(SQLLiteral.all) FROM \(ident: "planets") WHERE \(ident: "name") = \(bind: "Earth")")
///         .all(decoding: Planet.self)
public final class SQLRawBuilder: SQLQueryBuilder, SQLQueryFetcher {
    /// Raw query being built.
    @usableFromInline
    var sql: SQLQueryString

    /// See ``SQLQueryBuilder/database``.
    public var database: any SQLDatabase

    /// See ``SQLQueryBuilder/query``.
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
    public func raw(_ sql: SQLQueryString) -> SQLRawBuilder {
        .init(sql, on: self)
    }
}
