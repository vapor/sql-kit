extension SQLDatabase {
    /// Creates a new `SQLSelectBuilder`.
    ///
    /// ```sql
    /// db.select()
    ///     .column("*")
    ///     .from("planets")
    ///     .where("name", .equal, SQLBind("Earth"))
    ///     .all()
    /// ```
    public func select() -> SQLSelectBuilder {
        return .init(on: self)
    }
}

/// A builder for constructing, executing, and retrieving results from `SELECT` queries.
public final class SQLSelectBuilder: SQLQueryFetcher, SQLQueryBuilder, SQLSubqueryClauseBuilder {
    // See `SQLQueryBuilder.query`.
    public var query: SQLExpression {
        return self.select
    }
    
    // See `SQLSubqueryClauseBuilder.select`.
    public var select: SQLSelect
    
    // See `SQLQueryBuilder.database`.
    public var database: SQLDatabase
    
    /// Create a new `SQLSelectBuilder` on the given database.
    public init(on database: SQLDatabase) {
        self.select = .init()
        self.database = database
    }
}

// - MARK: Additional distinct clauses

extension SQLSelectBuilder {
    /// Adds a `DISTINCT` clause to the select statement and explicitly specifies columns to select,
    /// overwriting any previously specified columns.
    ///
    /// - Warning: This does _NOT_ invoke PostgreSQL's `DISTINCT ON (...)` syntax!
    ///
    /// - Returns: `self` for chaining.
    @discardableResult
    public func distinct(on column: String, _ columns: String...) -> Self {
        return self.distinct(on: ([column] + columns).map(SQLIdentifier.init(_:)))
    }
    
    /// Adds a `DISTINCT` clause to the select statement and explicitly specifies columns to select,
    /// overwriting any previously specified columns.
    ///
    /// - Warning: This does _NOT_ invoke PostgreSQL's `DISTINCT ON (...)` syntax!
    ///
    /// - Returns: `self` for chaining.
    @discardableResult
    public func distinct(on column: SQLExpression, _ columns: SQLExpression...) -> Self {
        return self.distinct(on: [column] + columns)
    }
    
    /// Adds a `DISTINCT` clause to the select statement and explicitly specifies columns to select,
    /// overwriting any previously specified columns.
    ///
    /// - Warning: This does _NOT_ invoke PostgreSQL's `DISTINCT ON (...)` syntax!
    ///
    /// - Returns: `self` for chaining.
    @discardableResult
    public func distinct(on columns: [SQLExpression]) -> Self {
        self.select.isDistinct = true
        self.select.columns = columns
        return self
    }
}
