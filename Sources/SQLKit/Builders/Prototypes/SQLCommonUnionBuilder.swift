/// Builds ``SQLUnion`` queries. Provides common behavior for ``SQLUnionBuilder`` and ``SQLUnionSubqueryBuilder``.
///
/// > Note: This abstraction is necessary only because ``SQLUnionBuilder`` did not take the use of unions in
/// > subqueries into account in its original design; it would break public API to fix it without this workaround.
public protocol SQLCommonUnionBuilder: SQLPartialResultBuilder {
    /// The union query generated by this builder.
    var union: SQLUnion { get set }
}

extension SQLCommonUnionBuilder {
    // See `SQLPartialResultBuilder.orderBys`.
    @inlinable
    public var orderBys: [any SQLExpression] {
        get { self.union.orderBys }
        set { self.union.orderBys = newValue }
    }
    
    // See `SQLPartialResultBuilder.limit`.
    @inlinable
    public var limit: Int? {
        get { self.union.limit }
        set { self.union.limit = newValue }
    }
    
    // See `SQLPartialResultBuilder.offset`.
    @inlinable
    public var offset: Int? {
        get { self.union.offset }
        set { self.union.offset = newValue }
    }

    /// Add a query to the union in `UNION DISTINCT` mode
    /// (all results from both queries are returned, with duplicates removed).
    @inlinable
    public func union(distinct query: SQLSelect) -> Self {
       self.union.add(query, joiner: .init(type: .union))
       return self
    }

    /// Add a query to the union in `UNION ALL` mode
    /// (all results from both queries are returned, with duplicates preserved).
    @inlinable
    public func union(all query: SQLSelect) -> Self {
       self.union.add(query, joiner: .init(type: .unionAll))
       return self
    }

    /// Add a query to the union in `INTERSECT DISTINCT` mode
    /// (only results that come from both queries are returned, with duplicates removed).
    @inlinable
    public func intersect(distinct query: SQLSelect) -> Self {
        self.union.add(query, joiner: .init(type: .intersect))
       return self
    }

    /// Add a query to the union in `INTERSECT ALL` mode
    /// (only results that come from both queries are returned, with duplicates preserved).
    @inlinable
    public func intersect(all query: SQLSelect) -> Self {
        self.union.add(query, joiner: .init(type: .intersectAll))
       return self
    }

    /// Add a query to the union in `EXCEPT DISTINCT` mode
    /// (only results that come from the left query but not the right are returned, with duplicates removed).
    @inlinable
    public func except(distinct query: SQLSelect) -> Self {
        self.union.add(query, joiner: .init(type: .except))
       return self
    }

    /// Add a query to the union in `EXCEPT ALL` mode
    /// (only results that come from the left query but not the right are returned, with duplicates preserved).
    @inlinable
    public func except(all query: SQLSelect) -> Self {
        self.union.add(query, joiner: .init(type: .exceptAll))
       return self
    }

    /// Call ``union(distinct:)-15xs8`` with a query generated by a builder.
    @inlinable
    public func union(distinct predicate: (any SQLSubqueryClauseBuilder) throws -> any SQLSubqueryClauseBuilder) rethrows -> Self {
        try self.union(distinct: predicate(SQLSubqueryBuilder()).select)
    }

    /// Call ``union(all:)-56f28`` with a query generated by a builder.
    @inlinable
    public func union(all predicate: (any SQLSubqueryClauseBuilder) throws -> any SQLSubqueryClauseBuilder) rethrows -> Self {
        try self.union(all: predicate(SQLSubqueryBuilder()).select)
    }

    /// Alias ``union(distinct:)-1ert0`` so it acts as the "default".
    @inlinable
    public func union(_ predicate: (any SQLSubqueryClauseBuilder) throws -> any SQLSubqueryClauseBuilder) rethrows -> Self {
        try self.union(distinct: predicate)
    }

    /// Call ``intersect(distinct:)-161s9`` with a query generated by a builder.
    @inlinable
    public func intersect(distinct predicate: (any SQLSubqueryClauseBuilder) throws -> any SQLSubqueryClauseBuilder) rethrows -> Self {
        try self.intersect(distinct: predicate(SQLSubqueryBuilder()).select)
    }

    /// Call ``intersect(all:)-1wiow`` with a query generated by a builder.
    @inlinable
    public func intersect(all predicate: (any SQLSubqueryClauseBuilder) throws -> any SQLSubqueryClauseBuilder) rethrows -> Self {
        try self.intersect(all: predicate(SQLSubqueryBuilder()).select)
    }

    /// Alias ``intersect(distinct:)-47w8a`` so it acts as the "default".
    @inlinable
    public func intersect(_ predicate: (any SQLSubqueryClauseBuilder) throws -> any SQLSubqueryClauseBuilder) rethrows -> Self {
        try self.intersect(distinct: predicate)
    }

    /// Call ``except(distinct:)-2ygq0`` with a query generated by a builder.
    @inlinable
    public func except(distinct predicate: (any SQLSubqueryClauseBuilder) throws -> any SQLSubqueryClauseBuilder) rethrows -> Self {
        try self.except(distinct: predicate(SQLSubqueryBuilder()).select)
    }

    /// Call ``except(all:)-5exbl`` with a query generated by a builder.
    @inlinable
    public func except(all predicate: (any SQLSubqueryClauseBuilder) throws -> any SQLSubqueryClauseBuilder) rethrows -> Self {
        try self.except(all: predicate(SQLSubqueryBuilder()).select)
    }

    /// Alias ``except(distinct:)-6vhbz`` so it acts as the "default".
    @inlinable
    public func except(_ predicate: (any SQLSubqueryClauseBuilder) throws -> any SQLSubqueryClauseBuilder) rethrows -> Self {
        try self.except(distinct: predicate)
    }
}

