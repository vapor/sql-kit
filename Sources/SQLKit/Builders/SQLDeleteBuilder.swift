/// Builds `SQLDelete` queries.
///
///     db.delete(from: Planet.self)
///         .where(\.name != "Earth").run()
///
/// See `SQLQueryBuilder` and `SQLPredicateBuilder` for more information.
public final class SQLDeleteBuilder: SQLQueryBuilder, SQLPredicateBuilder, SQLReturningBuilder {
    /// `Delete` query being built.
    public var delete: SQLDelete

    public var database: SQLDatabase

    public var query: SQLExpression {
        return self.delete
    }

    public var predicate: SQLExpression? {
        get { return self.delete.predicate }
        set { self.delete.predicate = newValue }
    }

    public var returning: SQLReturning? {
        get { return self.delete.returning }
        set { self.delete.returning = newValue }
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
    ///     db.delete(from: "planets")...
    ///
    /// - parameters:
    ///     - table: Table to delete from.
    /// - returns: Newly created `SQLDeleteBuilder`.
    public func delete(from table: String) -> SQLDeleteBuilder {
        return self.delete(from: SQLIdentifier(table))
    }
    
    /// Creates a new `SQLDeleteBuilder`.
    ///
    /// - parameters:
    ///     - table: Table to delete from.
    /// - returns: Newly created `SQLDeleteBuilder`.
    public func delete(from table: SQLExpression) -> SQLDeleteBuilder {
        return .init(.init(table: table), on: self)
    }
}
