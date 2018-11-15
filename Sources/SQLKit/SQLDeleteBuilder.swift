/// Builds `SQLDelete` queries.
///
///     conn.delete(from: Planet.self)
///         .where(\.name != "Earth").run()
///
/// See `SQLQueryBuilder` and `SQLPredicateBuilder` for more information.
public final class SQLDeleteBuilder<Database>: SQLQueryBuilder, SQLPredicateBuilder
    where Database: SQLDatabase
{
    /// `Delete` query being built.
    public var delete: Database.Query.Delete
    
    /// See `SQLQueryBuilder`.
    public var database: Database
    
    /// See `SQLQueryBuilder`.
    public var query: Database.Query {
        return .delete(delete)
    }
    
    /// See `SQLWhereBuilder`.
    public var predicate: Database.Query.Delete.Expression? {
        get { return delete.predicate }
        set { delete.predicate = newValue }
    }
    
    /// Creates a new `SQLDeleteBuilder`.
    public init(_ delete: Database.Query.Delete, on database: Database) {
        self.delete = delete
        self.database = database
    }
}

// MARK: Connection

extension SQLDatabase {
    /// Creates a new `SQLDeleteBuilder`.
    ///
    ///     conn.delete(from: Planet.self)...
    ///
    /// - parameters:
    ///     - table: Table to delete from.
    /// - returns: Newly created `SQLDeleteBuilder`.
    public func delete(from table: Query.Delete.TableIdentifier) -> SQLDeleteBuilder<Self> {
        return .init(.delete(table), on: self)
    }
}
