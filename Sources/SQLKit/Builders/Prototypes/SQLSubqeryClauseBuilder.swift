/// A builder which can construct - but _not_ execute - a complete `SELECT` query.
/// Useful for building CTEs, `CREATE TABLE ... SELECT` clauses, etc., not to
/// mention actual `SELECT` queries.
///
/// Due to unfortunate naming choices which this API is now stuck with until a major version bump,
/// this protocol is very easily confused with ``SQLSubqueryBuilder``. For clarification, this protocol
/// provides methods common to the construction of `SELECT` subqueries, whereas ``SQLSubqueryBuilder`` is
/// a concrete type which conforms to this protocol and provides support for embedding ``SQLSubquery``
/// expressions in other queries.
///
/// > Important: Despite the use of the term "subquery", this builder does not provide
/// > methods for specifying subquery operators (e.g. `ANY`, `SOME`) or CTE clauses (`WITH`),
/// > nor does it enclose its result in grouping parenthesis, as all of these formations are
/// > context-specific and are the purview of builders that conform to this protocol.
///
/// > Note: The primary motivation for the existence of this protocol is to make it easier
/// > to construct `SELECT` queries without specifying a database or providing the
/// > ``SQLQueryBuilder`` and ``SQLQueryFetcher`` methods in inappropriate contexts.
public protocol SQLSubqueryClauseBuilder:
    SQLJoinBuilder,
    SQLPredicateBuilder,
    SQLSecondaryPredicateBuilder,
    SQLPartialResultBuilder,
    SQLAliasedColumnListBuilder
{
    /// The ``SQLSelect`` query under construction.
    var select: SQLSelect { get set }
}

extension SQLSubqueryClauseBuilder {
    // See `SQLJoinBuilder.joins`.
    public var joins: [any SQLExpression] {
        get { self.select.joins }
        set { self.select.joins = newValue }
    }

    // See `SQLPredicateBuilder.predicate`.
    public var predicate: (any SQLExpression)? {
        get { return self.select.predicate }
        set { self.select.predicate = newValue }
    }

    // See `SQLSecondaryPredicateBuilder.secondaryPredicate`.
    public var secondaryPredicate: (any SQLExpression)? {
        get { return self.select.having }
        set { self.select.having = newValue }
    }

    // See `SQLPartialResultBuilder.orderBys`.
    public var orderBys: [any SQLExpression] {
        get { self.select.orderBy }
        set { self.select.orderBy = newValue }
    }
    
    // See `SQLPartialResultBuilder.limit`.
    public var limit: Int? {
        get { self.select.limit }
        set { self.select.limit = newValue }
    }
    
    // See `SQLPartialResultBuilder.offset`.
    public var offset: Int? {
        get { self.select.offset }
        set { self.select.offset = newValue }
    }
    
    // See `SQLUnqualifiedColumnListBuilder.columnList`.
    public var columnList: [any SQLExpression] {
        get { self.select.columns }
        set { self.select.columns = newValue }
    }
    
    // See `SQLAliasedColumnListBuilder.columns`.
    public var columns: [any SQLExpression] {
        get { self.select.columns }
        set { self.select.columns = newValue }
    }
}

// MARK: - Distinct

extension SQLSubqueryClauseBuilder {
    /// Adds a `DISTINCT` clause to the query.
    @inlinable
    @discardableResult
    public func distinct() -> Self {
        self.select.isDistinct = true
        return self
    }

    /// Adds a `DISTINCT` clause to the select statement and explicitly specifies columns to select,
    /// overwriting any previously specified columns.
    ///
    /// > Warning: This does _NOT_ invoke PostgreSQL's `DISTINCT ON (...)` syntax!
    @inlinable
    @discardableResult
    public func distinct(on column: String, _ columns: String...) -> Self {
        self.distinct(on: ([column] + columns).map(SQLIdentifier.init(_:)))
    }
    
    /// Adds a `DISTINCT` clause to the select statement and explicitly specifies columns to select,
    /// overwriting any previously specified columns.
    ///
    /// > Warning: This does _NOT_ invoke PostgreSQL's `DISTINCT ON (...)` syntax!
    @inlinable
    @discardableResult
    public func distinct(on column: any SQLExpression, _ columns: any SQLExpression...) -> Self {
        self.distinct(on: [column] + columns)
    }
    
    /// Adds a `DISTINCT` clause to the select statement and explicitly specifies columns to select,
    /// overwriting any previously specified columns.
    ///
    /// > Warning: This does _NOT_ invoke PostgreSQL's `DISTINCT ON (...)` syntax!
    @inlinable
    @discardableResult
    public func distinct(on columns: [any SQLExpression]) -> Self {
        self.select.isDistinct = true
        self.select.columns = columns
        return self
    }
}

// MARK: - From

extension SQLSubqueryClauseBuilder {
    /// Include the given table in the list of those used by the query, without performing an
    /// explicit join.
    ///
    /// - Parameter table: The name of the table to use.
    /// - Returns: `self` for chaining.
    @inlinable
    @discardableResult
    public func from(_ table: String) -> Self {
        self.from(SQLIdentifier(table))
    }
    
    /// Include the given table in the list of those used by the query, without performing an
    /// explicit join.
    ///
    /// - Parameter table: An expression identifying the table to use.
    /// - Returns: `self` for chaining.
    @inlinable
    @discardableResult
    public func from(_ table: any SQLExpression) -> Self {
        self.select.tables.append(table)
        return self
    }
    
    /// Include the given table and an alias for it in the list of those used by the query, without
    /// performing an explicit join.
    @inlinable
    @discardableResult
    public func from(_ table: String, as alias: String) -> Self {
        self.from(SQLIdentifier(table), as: SQLIdentifier(alias))
    }
    
    /// Include the given table and an alias for it in the list of those used by the query, without
    /// performing an explicit join.
    @inlinable
    @discardableResult
    public func from(_ table: any SQLExpression, as alias: any SQLExpression) -> Self {
        self.from(SQLAlias(table, as: alias))
    }
}

// MARK: - Group By

extension SQLSubqueryClauseBuilder {
    /// Adds a `GROUP BY` clause to the query with the specified column.
    @inlinable
    @discardableResult
    public func groupBy(_ column: String) -> Self {
        self.groupBy(SQLColumn(column))
    }

    /// Adds a `GROUP BY` clause to the query with the specified expression.
    @inlinable
    @discardableResult
    public func groupBy(_ expression: any SQLExpression) -> Self {
        self.select.groupBy.append(expression)
        return self
    }
}

// MARK: - Locking

extension SQLSubqueryClauseBuilder {
    /// Adds a locking clause to this query. If called more than once, the last call wins.
    ///
    /// ```swift
    /// db.select()...for(.update)
    /// db.select()...for(.share)
    /// ```
    ///
    /// Also referred to as locking or "consistent" reads, the locking clause syntax locks
    /// all selected rows for the duration of the current transaction with a type of lock
    /// determined by the specific locking clause and the underlying database's support for
    /// this construct.
    ///
    /// > Warning: If the database in use does not support locking reads, the locking clause
    /// > will be silently ignored regardless of its value.
    @inlinable
    @discardableResult
    public func `for`(_ lockingClause: SQLLockingClause) -> Self {
        self.lockingClause(lockingClause as any SQLExpression)
    }

    /// Adds a locking clause to this query. If called more than once, the last call wins.
    ///
    /// ```swift
    /// db.select()...lockingClause(...)
    /// ```
    ///
    /// Also referred to as locking or "consistent" reads, the locking clause syntax locks
    /// all selected rows for the duration of the current transaction with a type of lock
    /// determined by the specific locking clause and the underlying database's support for
    /// this construct.
    ///
    /// > Note: This method allows providing an arbitrary SQL expression as the locking clause.
    ///
    /// > Warning: If the database in use does not support locking reads, the locking clause
    /// > will be silently ignored regardless of its value.
    @inlinable
    @discardableResult
    public func lockingClause(_ lockingClause: any SQLExpression) -> Self {
        self.select.lockingClause = lockingClause
        return self
    }
}
