/// Builds `SQLDelete` queries.
///
///     conn.delete(from: Planet.self)
///         .where(\.name != "Earth").run()
///
/// See `SQLQueryBuilder` and `SQLPredicateBuilder` for more information.
public final class SQLDeleteBuilder<Connection>: SQLQueryBuilder, SQLPredicateBuilder
    where Connection: SQLConnectable
{
    /// `Delete` query being built.
    public var delete: Connection.Connection.Query.Delete
    
    /// See `SQLQueryBuilder`.
    public var connection: Connection
    
    /// See `SQLQueryBuilder`.
    public var query: Connection.Connection.Query {
        return .delete(delete)
    }
    
    /// See `SQLWhereBuilder`.
    public var predicate: Connection.Connection.Query.Delete.Expression? {
        get { return delete.predicate }
        set { delete.predicate = newValue }
    }
    
    /// Creates a new `SQLDeleteBuilder`.
    public init(_ delete: Connection.Connection.Query.Delete, on connection: Connection) {
        self.delete = delete
        self.connection = connection
    }
}

// MARK: Connection

extension SQLConnectable {
    /// Creates a new `SQLDeleteBuilder`.
    ///
    ///     conn.delete(from: Planet.self)...
    ///
    /// - parameters:
    ///     - table: Table to delete from.
    /// - returns: Newly created `SQLDeleteBuilder`.
    public func delete<Table>(from table: Table.Type) -> SQLDeleteBuilder<Self>
        where Table: SQLTable
    {
        return .init(.delete(.table(Table.self)), on: self)
    }
}
