public final class SQLCreateIndexBuilder<Connection>: SQLQueryBuilder
    where Connection: SQLConnection
{
    /// See `SQLColumnBuilder`.
    public typealias ColumnDefinition = Connection.Query.AlterTable.ColumnDefinition
    
    /// `AlterTable` query being built.
    public var createIndex: Connection.Query.CreateIndex
    
    /// See `SQLQueryBuilder`.
    public var connection: Connection
    
    /// See `SQLQueryBuilder`.
    public var query: Connection.Query {
        return .createIndex(createIndex)
    }
    
    public func unique() -> Self {
        createIndex.modifier = .unique
        return self
    }
    
    /// Creates a new `SQLCreateIndexBuilder`.
    public init(_ createIndex: Connection.Query.CreateIndex, on connection: Connection) {
        self.createIndex = createIndex
        self.connection = connection
    }
}

// MARK: Connection

extension DatabaseQueryable where Query: SQLQuery {
    /// Creates a new `SQLCreateIndexBuilder`.
    ///
    ///     conn.create(index: "foo", on: \Planet.name)...
    ///
    /// - parameters:
    ///     - table: Table to create index on.
    /// - returns: `SQLCreateIndexBuilder`.
    public func create<T, A>(
        index identifier: Query.CreateIndex.Identifier,
        on column: KeyPath<T, A>
    ) -> SQLCreateIndexBuilder<Self>
        where T: SQLTable
    {
        return .init(.createIndex(identifier, .table(T.self), [.keyPath(column)]), on: self)
    }
    
    /// Creates a new `SQLCreateIndexBuilder`.
    ///
    ///     conn.create(index: "foo", on: \Planet.name, \Planet.id)...
    ///
    /// - parameters:
    ///     - table: Table to create index on.
    /// - returns: `SQLCreateIndexBuilder`.
    public func create<T, A, B>(
        index identifier: Query.CreateIndex.Identifier,
        on a: KeyPath<T, A>, _ b: KeyPath<T, B>
    ) -> SQLCreateIndexBuilder<Self>
        where T: SQLTable
    {
        return .init(.createIndex(identifier, .table(T.self), [.keyPath(a), .keyPath(b)]), on: self)
    }
    
    /// Creates a new `SQLCreateIndexBuilder`.
    ///
    ///     conn.create(index: "foo", on: \Planet.name, \Planet.id, \Planet.galaxyID)...
    ///
    /// - parameters:
    ///     - table: Table to create index on.
    /// - returns: `SQLCreateIndexBuilder`.
    public func create<T, A, B, C>(
        index identifier: Query.CreateIndex.Identifier,
        on a: KeyPath<T, A>, _ b: KeyPath<T, B>, _ c: KeyPath<T, C>
    ) -> SQLCreateIndexBuilder<Self>
        where T: SQLTable
    {
        return .init(.createIndex(identifier, .table(T.self), [.keyPath(a), .keyPath(b), .keyPath(c)]), on: self)
    }
}
