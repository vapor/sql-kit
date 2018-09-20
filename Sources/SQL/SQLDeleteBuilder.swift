/// Builds `SQLDelete` queries.
///
///     conn.delete(from: Planet.self)
///         .where(\.name != "Earth").run()
///
/// See `SQLQueryBuilder` and `SQLPredicateBuilder` for more information.
public final class SQLDeleteBuilder<Connectable>: SQLQueryBuilder, SQLPredicateBuilder
    where Connectable: SQLConnectable
{
    /// `Delete` query being built.
    public var delete: Connectable.Connection.Query.Delete
    
    /// See `SQLQueryBuilder`.
    public var connectable: Connectable
    
    /// See `SQLQueryBuilder`.
    public var query: Connectable.Connection.Query {
        return .delete(delete)
    }
    
    /// See `SQLWhereBuilder`.
    public var predicate: Connectable.Connection.Query.Delete.Expression? {
        get { return delete.predicate }
        set { delete.predicate = newValue }
    }
    
    /// Creates a new `SQLDeleteBuilder`.
    public init(_ delete: Connectable.Connection.Query.Delete, on connectable: Connectable) {
        self.delete = delete
        self.connectable = connectable
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
