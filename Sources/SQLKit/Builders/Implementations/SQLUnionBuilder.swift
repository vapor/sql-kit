/// Builds top-level ``SQLUnion`` queries which may be executed on their own.
public final class SQLUnionBuilder: SQLQueryBuilder, SQLQueryFetcher, SQLCommonUnionBuilder {
    // See `SQLCommonUnionBuilder.union`.
    public var union: SQLUnion

    // See `SQLQueryBuilder.database`.
    public var database: any SQLDatabase

    // See `SQLQueryBuilder.query`.
    @inlinable
    public var query: any SQLExpression {
        self.union
    }

    /// Create a new ``SQLUnionBuilder``.
    @inlinable
    public init(on database: any SQLDatabase, initialQuery: SQLSelect) {
        self.union = .init(initialQuery: initialQuery)
        self.database = database
    }
}

extension SQLDatabase {
    /// Create a new ``SQLUnionBuilder``, providing a builder to create the first query.
    @inlinable
    public func union(_ predicate: (SQLSelectBuilder) throws -> SQLSelectBuilder) rethrows -> SQLUnionBuilder {
        .init(on: self, initialQuery: try predicate(.init(on: self)).select)
    }
}

extension SQLSelectBuilder {
    // See `SQLCommonUnionBuilder.union(distinct:)`.
    @inlinable
    public func union(distinct predicate: (any SQLSubqueryClauseBuilder) throws -> any SQLSubqueryClauseBuilder) rethrows -> SQLUnionBuilder {
        try .init(on: self.database, initialQuery: self.select).union(distinct: predicate)
    }

    // See `SQLCommonUnionBuilder.union(all:)`.
    @inlinable
    public func union(all predicate: (any SQLSubqueryClauseBuilder) throws -> any SQLSubqueryClauseBuilder) rethrows -> SQLUnionBuilder {
        try .init(on: self.database, initialQuery: self.select).union(all: predicate)
    }
    
    // See `SQLCommonUnionBuilder.union(_:)`.
    @inlinable
    public func union(_ predicate: (any SQLSubqueryClauseBuilder) throws -> any SQLSubqueryClauseBuilder) rethrows -> SQLUnionBuilder {
        try self.union(distinct: predicate)
    }

    // See `SQLCommonUnionBuilder.intersect(distinct:)`.
    @inlinable
    public func intersect(distinct predicate: (any SQLSubqueryClauseBuilder) throws -> any SQLSubqueryClauseBuilder) rethrows -> SQLUnionBuilder {
        try .init(on: self.database, initialQuery: self.select).intersect(distinct: predicate)
    }

    // See `SQLCommonUnionBuilder.intersect(all:)`.
    @inlinable
    public func intersect(all predicate: (any SQLSubqueryClauseBuilder) throws -> any SQLSubqueryClauseBuilder) rethrows -> SQLUnionBuilder {
        try .init(on: self.database, initialQuery: self.select).intersect(all: predicate)
    }
    
    // See `SQLCommonUnionBuilder.intersect(_:)`.
    @inlinable
    public func intersect(_ predicate: (any SQLSubqueryClauseBuilder) throws -> any SQLSubqueryClauseBuilder) rethrows -> SQLUnionBuilder {
        try self.intersect(distinct: predicate)
    }

    // See `SQLCommonUnionBuilder.except(distinct:)`.
    @inlinable
    public func except(distinct predicate: (any SQLSubqueryClauseBuilder) throws -> any SQLSubqueryClauseBuilder) rethrows -> SQLUnionBuilder {
        try .init(on: self.database, initialQuery: self.select).except(distinct: predicate)
    }

    // See `SQLCommonUnionBuilder.except(all:)`.
    @inlinable
    public func except(all predicate: (any SQLSubqueryClauseBuilder) throws -> any SQLSubqueryClauseBuilder) rethrows -> SQLUnionBuilder {
        try .init(on: self.database, initialQuery: self.select).except(all: predicate)
    }

    // See `SQLCommonUnionBuilder.except(_:)`.
    @inlinable
    public func except(_ predicate: (any SQLSubqueryClauseBuilder) throws -> any SQLSubqueryClauseBuilder) rethrows -> SQLUnionBuilder {
        try self.except(distinct: predicate)
    }
}
