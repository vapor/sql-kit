/// Builds `SQLDelete` queries.
///
///     conn.delete(from: Planet.self)
///         .where(\.name != "Earth").run()
///
/// See `SQLQueryBuilder` and `SQLPredicateBuilder` for more information.
public final class SQLDeleteBuilder: SQLQueryBuilder, SQLPredicateBuilder {
    /// `Delete` query being built.
    public var delete: SQLDelete
    
    /// See `SQLQueryBuilder`.
    public var database: SQLDatabase
    
    /// See `SQLQueryBuilder`.
    public var query: SQLExpression {
        return self.delete
    }
    
    /// See `SQLWhereBuilder`.
    public var predicate: SQLExpression? {
        get { return self.delete.predicate }
        set { self.delete.predicate = newValue }
    }
    
    /// Creates a new `SQLDeleteBuilder`.
    public init(_ delete: SQLDelete, on database: SQLDatabase) {
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
    public func delete(from table: String) -> SQLDeleteBuilder {
        return self.delete(from: SQLIdentifier(table))
    }
    
    /// Creates a new `SQLDeleteBuilder`.
    ///
    ///     conn.delete(from: "planets")...
    ///
    /// - parameters:
    ///     - table: Table to delete from.
    /// - returns: Newly created `SQLDeleteBuilder`.
    public func delete(from table: SQLExpression) -> SQLDeleteBuilder {
        return .init(.init(table: table), on: self)
    }
}
