/// Builds `SQLCreateIndex` queries.
///
///     db.create(index: "planet_name_unique").on("planet").column("name").unique().run()
///
/// See `SQLCreateIndex`.
public final class SQLCreateIndexBuilder: SQLQueryBuilder {
    /// `AlterTable` query being built.
    public var createIndex: SQLCreateIndex
    
    /// See `SQLQueryBuilder`.
    public var database: SQLDatabase
    
    /// See `SQLQueryBuilder`.
    public var query: SQLExpression {
        return self.createIndex
    }
    
    /// Adds `UNIQUE` modifier to the index being created.
    @discardableResult
    public func unique() -> Self {
        self.createIndex.modifier = SQLColumnConstraintAlgorithm.unique
        return self
    }
    
    /// Creates a new `SQLCreateIndexBuilder`.
    ///
    ///     db.create(index: "foo").on("planets")...
    ///
    /// - parameters:
    ///     - table: Table to create index on.
    /// - returns: `SQLCreateIndexBuilder`.
    @discardableResult
    public func on(_ table: String) -> Self {
        return self.on(SQLIdentifier(table))
    }
    
    /// Creates a new `SQLCreateIndexBuilder`.
    ///
    ///     db.create(index: "foo").on("planets")...
    ///
    /// - parameters:
    ///     - table: Table to create index on.
    /// - returns: `SQLCreateIndexBuilder`.
    @discardableResult
    public func on(_ column: SQLExpression) -> Self {
        self.createIndex.table = column
        return self
    }
    
    /// Creates a new `SQLCreateIndexBuilder`.
    ///
    ///     db.create(index: "foo").column("name")...
    ///
    /// - parameters:
    ///     - column: Column to create index on.
    /// - returns: `SQLCreateIndexBuilder`.
    @discardableResult
    public func column(_ column: String) -> Self {
        return self.column(SQLIdentifier(column))
    }
    
    /// Creates a new `SQLCreateIndexBuilder`.
    ///
    ///     db.create(index: "foo").column("name")...
    ///
    /// - parameters:
    ///     - column: Column to create index on.
    /// - returns: `SQLCreateIndexBuilder`.
    @discardableResult
    public func column(_ column: SQLExpression) -> Self {
        self.createIndex.columns.append(column)
        return self
    }
    
    /// Creates a new `SQLCreateIndexBuilder`.
    public init(_ createIndex: SQLCreateIndex, on database: SQLDatabase) {
        self.createIndex = createIndex
        self.database = database
    }
}

// MARK: Connection

extension SQLDatabase {
    /// Creates a new `SQLCreateIndexBuilder`.
    ///
    ///     db.create(index: "foo")...
    ///
    /// - parameters:
    ///     - name: Name for this index.
    /// - returns: `SQLCreateIndexBuilder`.
    public func create(
        index name: String
    ) -> SQLCreateIndexBuilder {
        return self.create(index: SQLIdentifier(name))
    }
    
    /// Creates a new `SQLCreateIndexBuilder`.
    ///
    ///     db.create(index: "foo")...
    ///
    /// - parameters:
    ///     - name: Name for this index.
    /// - returns: `SQLCreateIndexBuilder`.
    public func create(
        index name: SQLExpression
    ) -> SQLCreateIndexBuilder {
        return .init(.init(name: name), on: self)
    }
}
