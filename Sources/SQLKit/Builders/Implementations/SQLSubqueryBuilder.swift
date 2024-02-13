/// Builds ``SQLSubquery`` queries.
///
/// > Note: This is an even thinner wrapper over ``SQLSubqueryClauseBuilder`` than is ``SQLSelectBuilder``.
public final class SQLSubqueryBuilder: SQLSubqueryClauseBuilder {
    /// The ``SQLSubquery`` built by this builder.
    public var query: SQLSubquery
    
    // See `SQLSubqueryClauseBuilder.select`.
    @inlinable
    public var select: SQLSelect {
        get { self.query.subquery }
        set { self.query.subquery = newValue }
    }
    
    /// Create a new ``SQLSubqueryBuilder``.
    @inlinable
    public init() {
        self.query = .init(.init())
    }
}

extension SQLSubquery {
    /// Create a ``SQLSubquery`` expression using an inline query builder.
    ///
    /// Example usage:
    ///
    /// ```swift
    /// try await db.update("foos")
    ///     .set(SQLIdentifier("bar_id"), to: SQLSubquery.select { $0
    ///         .column("id")
    ///         .from("bars")
    ///         .where("baz", .notEqual, "bamf")
    ///     })
    ///     .run()
    /// ```
    ///
    /// > Note: At this time, only `SELECT` subqueries are supported by the API.
    @inlinable
    public static func select(
        _ build: (any SQLSubqueryClauseBuilder) throws -> any SQLSubqueryClauseBuilder
    ) rethrows -> some SQLExpression {
        let builder = SQLSubqueryBuilder()
        
        _ = try build(builder)
        return builder.query
    }
}

/// Formerly a separate builder used to construct `SELECT` subqueries in `CREATE TABLE` queries, now a deprecated
/// alias for the more general-purpose ``SQLSubqueryBuilder``.
@available(*, deprecated, renamed: "SQLSubqueryBuilder", message: "Superseded by SQLSubqueryBuilder")
public typealias SQLCreateTableAsSubqueryBuilder = SQLSubqueryBuilder
