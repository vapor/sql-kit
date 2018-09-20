/// Builds `SQLCreateIndex` queries.
///
///     conn.create(index: "planet_name_unique").on(\Planet.name).unique().run()
///
/// See `SQLCreateIndex`.
public final class SQLCreateIndexBuilder<Connectable>: SQLQueryBuilder
    where Connectable: SQLConnectable
{
    /// See `SQLColumnBuilder`.
    public typealias ColumnDefinition = Connectable.Connection.Query.AlterTable.ColumnDefinition
    
    /// `AlterTable` query being built.
    public var createIndex: Connectable.Connection.Query.CreateIndex
    
    /// See `SQLQueryBuilder`.
    public var connectable: Connectable
    
    /// See `SQLQueryBuilder`.
    public var query: Connectable.Connection.Query {
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
    public init(_ createIndex: Connectable.Connection.Query.CreateIndex, on connectable: Connectable) {
        self.createIndex = createIndex
        self.connectable = connectable
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
