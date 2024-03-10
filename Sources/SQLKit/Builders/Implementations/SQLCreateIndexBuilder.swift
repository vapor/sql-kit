/// Builds ``SQLCreateIndex`` queries.
public final class SQLCreateIndexBuilder: SQLQueryBuilder {
    /// ``SQLCreateIndex`` query being built.
    public var createIndex: SQLCreateIndex
    
    // See `SQLQueryBuilder.database`.
    public var database: any SQLDatabase
    
    // See `SQLQueryBuilder.query`.
    @inlinable
    public var query: any SQLExpression {
        self.createIndex
    }
    
    /// Create a new ``SQLCreateIndexBuilder``.
    @inlinable
    public init(_ createIndex: SQLCreateIndex, on database: any SQLDatabase) {
        self.createIndex = createIndex
        self.database = database
    }

    /// Adds `UNIQUE` modifier to the index being created.
    @inlinable
    @discardableResult
    public func unique() -> Self {
        self.createIndex.modifier = SQLColumnConstraintAlgorithm.unique
        return self
    }
    
    /// Specify a table to operate on.
    @inlinable
    @discardableResult
    public func on(_ table: String) -> Self {
        self.on(SQLIdentifier(table))
    }
    
    /// Specify a table to operate on.
    @inlinable
    @discardableResult
    public func on(_ table: any SQLExpression) -> Self {
        self.createIndex.table = table
        return self
    }
    
    /// Specify a column to include in the created index.
    @inlinable
    @discardableResult
    public func column(_ column: String) -> Self {
        self.column(SQLIdentifier(column))
    }
    
    /// Specify a column to include in the created index.
    @inlinable
    @discardableResult
    public func column(_ column: any SQLExpression) -> Self {
        self.createIndex.columns.append(column)
        return self
    }
}

// MARK: Connection

extension SQLDatabase {
    /// Creates a new ``SQLCreateIndexBuilder``.
    @inlinable
    public func create(index name: String) -> SQLCreateIndexBuilder {
        self.create(index: SQLIdentifier(name))
    }
    
    /// Creates a new ``SQLCreateIndexBuilder``.
    @inlinable
    public func create(index name: any SQLExpression) -> SQLCreateIndexBuilder {
        .init(.init(name: name), on: self)
    }
}
