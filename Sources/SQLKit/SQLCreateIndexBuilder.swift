/// Builds `SQLCreateIndex` queries.
///
///     conn.create(index: "planet_name_unique").on(\Planet.name).unique().run()
///
/// See `SQLCreateIndex`.
public final class SQLCreateIndexBuilder<Database>: SQLQueryBuilder
    where Database: SQLDatabase
{
    /// See `SQLColumnBuilder`.
    public typealias ColumnDefinition = Database.Query.AlterTable.ColumnDefinition
    
    /// `AlterTable` query being built.
    public var createIndex: Database.Query.CreateIndex
    
    /// See `SQLQueryBuilder`.
    public var database: Database
    
    /// See `SQLQueryBuilder`.
    public var query: Database.Query {
        return .createIndex(createIndex)
    }
    
    /// Adds `UNIQUE` modifier to the index being created.
    public func unique() -> Self {
        createIndex.modifier = .unique
        return self
    }
    
    /// Creates a new `SQLCreateIndexBuilder`.
    ///
    ///     conn.create(index: "foo").on(\Planet.name)...
    ///
    /// - parameters:
    ///     - column: Key path to column to add index to.
    /// - returns: `SQLCreateIndexBuilder`.
    public func on(_ column: Database.Query.CreateIndex.ColumnIdentifier) -> Self {
        self.createIndex.columns.append(column)
        return self
    }
    
    /// Creates a new `SQLCreateIndexBuilder`.
    public init(_ createIndex: Database.Query.CreateIndex, on database: Database) {
        self.createIndex = createIndex
        self.database = database
    }
}

// MARK: Connection

extension SQLDatabase {
    /// Creates a new `SQLCreateIndexBuilder`.
    ///
    ///     conn.create(index: "foo")...
    ///
    /// - parameters:
    ///     - identifier: Name for this index.
    /// - returns: `SQLCreateIndexBuilder`.
    public func create(
        index identifier: Self.Query.CreateIndex.Identifier
    ) -> SQLCreateIndexBuilder<Self> {
        return .init(.createIndex(name: identifier), on: self)
    }
}
