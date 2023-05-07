/// Builds ``SQLSelect`` queries.
///
/// - Note: This is effectively nothing but a concrete conformance to ``SQLSubqueryClauseBuilder``
///   which provides storage for the ``SQLSelect`` and adds ``SQLQueryFetcher`` so the query can
///   actually be executed.
public final class SQLSelectBuilder: SQLQueryBuilder, SQLQueryFetcher, SQLSubqueryClauseBuilder {
    /// See ``SQLSubqueryClauseBuilder/select``.
    public var select: SQLSelect
    
    /// See ``SQLQueryBuilder/database``.
    public var database: any SQLDatabase
    
    /// See ``SQLQueryBuilder/query``.
    @inlinable
    public var query: any SQLExpression {
        self.select
    }
    
    /// Create a new ``SQLSelectBuilder``.
    @inlinable
    public init(on database: any SQLDatabase) {
        self.select = .init()
        self.database = database
    }
}

extension SQLDatabase {
    /// Create a new ``SQLSelectBuilder``.
    @inlinable
    public func select() -> SQLSelectBuilder {
        .init(on: self)
    }
}

