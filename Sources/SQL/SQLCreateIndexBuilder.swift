/// Builds `SQLCreateIndex` queries.
///
///     conn.create(index: "planet_name_unique").on(\Planet.name).unique().run()
///
/// See `SQLCreateIndex`.
public final class SQLCreateIndexBuilder<Connection>: SQLQueryBuilder
    where Connection: SQLConnectable
{
    /// See `SQLColumnBuilder`.
    public typealias ColumnDefinition = Connection.Connection.Query.AlterTable.ColumnDefinition
    
    /// `AlterTable` query being built.
    public var createIndex: Connection.Connection.Query.CreateIndex
    
    /// See `SQLQueryBuilder`.
    public var connection: Connection
    
    /// See `SQLQueryBuilder`.
    public var query: Connection.Connection.Query {
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
    public func on<T, A>(_ column: KeyPath<T, A>) -> Self
        where T: SQLTable
    {
        createIndex.columns.append(.keyPath(column))
        return self
    }
    
    /// Creates a new `SQLCreateIndexBuilder`.
    public init(_ createIndex: Connection.Connection.Query.CreateIndex, on connection: Connection) {
        self.createIndex = createIndex
        self.connection = connection
    }
}

// MARK: Connection

extension SQLConnectable {
    /// Creates a new `SQLCreateIndexBuilder`.
    ///
    ///     conn.create(index: "foo")...
    ///
    /// - parameters:
    ///     - identifier: Name for this index.
    /// - returns: `SQLCreateIndexBuilder`.
    public func create(
        index identifier: Connection.Query.CreateIndex.Identifier
    ) -> SQLCreateIndexBuilder<Self> {
        return .init(.createIndex(identifier), on: self)
    }
}
