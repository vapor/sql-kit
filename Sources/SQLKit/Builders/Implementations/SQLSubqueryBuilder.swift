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

/// Builds ``SQLUnion`` subqueries meant to be embedded within other queries.
public final class SQLUnionSubqueryBuilder: SQLCommonUnionBuilder {
    /// The union subquery built by this builder.
    public var subquery: SQLUnionSubquery
    
    // See `SQLCommonUnionBuilder.union`.
    public var union: SQLUnion {
        get { self.subquery.subquery }
        set { self.subquery.subquery = newValue }
    }
    
    /// Create a new ``SQLUnionSubqueryBuilder``.
    @inlinable
    public init(initialQuery: SQLSelect) {
        self.subquery = .init(.init(initialQuery: initialQuery))
    }
    
    /// Render the builder's combined unions into an ``SQLExpression`` which may be used as a subquery.
    ///
    /// The same effect can be achieved by writing `.union` instead of `.finish()`, but providing an
    /// explicit "complete the union" API improves readability and makes the intent more explicit, whereas
    /// using yet _another_ meaning of the term "union" for the _third_ time in rapid succession is nothing
    /// but confusing. It was confusing enough coming up with the subquery API for unions at all.
    ///
    /// Example:
    ///
    /// ```swift
    /// try await db.update("foos")
    ///     .set(SQLIdentifier("bar_id"), to: SQLSubquery
    ///         .union { $0
    ///             .column("id")
    ///             .from("bars")
    ///             .where("baz", .notEqual, "bamf")
    ///         }
    ///         .union(all: { $0
    ///             .column("id")
    ///             .from("bars")
    ///             .where("baz", .equal, "bop")
    ///         })
    ///         .finish()
    ///     )
    ///     .run()
    /// ```
    @inlinable
    public func finish() -> some SQLExpression {
        self.subquery
    }
}

extension SQLSubquery {
    /// Create a ``SQLSubquery`` expression using an inline query builder which generates the first `SELECT`
    /// query in a `UNION`.
    ///
    /// Example usage:
    ///
    /// ```swift
    /// try await db.update("foos")
    ///     .set(SQLIdentifier("bar_id"), to: SQLSubquery
    ///         .union { $0
    ///             .column("id")
    ///             .from("bars")
    ///             .where("baz", .notEqual, "bamf")
    ///         }
    ///         .union(all: { $0
    ///             .column("id")
    ///             .from("bars")
    ///             .where("baz", .equal, "bop")
    ///         })
    ///         .finish()
    ///     )
    ///     .run()
    /// ```
    ///
    /// > Note: The need to start with `.union` and call `.finish()`, rather than using ``SQLSubquery/select(_:)`` and
    /// > chaining `.union()` within that builder, is the result of yet another of the design flaws making use of
    /// > unions in subqueries far more involved than ought to be necessary.
    @inlinable
    public static func union(
        _ initialBuild: (any SQLSubqueryClauseBuilder) throws -> any SQLSubqueryClauseBuilder
    ) rethrows -> SQLUnionSubqueryBuilder {
        .init(initialQuery: try initialBuild(SQLSubqueryBuilder()).select)
    }
}
