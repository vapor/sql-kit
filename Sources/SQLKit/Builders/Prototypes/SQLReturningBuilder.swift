/// Common definitions for any query builder which can return values from data-mutating queries.
public protocol SQLReturningBuilder: SQLQueryBuilder {
    /// The specification of what the query should return, if any.
    var returning: SQLReturning? { get set }
}

extension SQLReturningBuilder {
    /// Specify a list of columns to be part of the result set of the query.
    ///
    /// - Returns: A ``SQLReturningResultBuilder`` which must be used to execute the query.
    @inlinable
    public func returning(_ columns: String...) -> SQLReturningResultBuilder<Self> {
        self.returning(columns.map { SQLColumn($0 == "*" ? SQLLiteral.all : SQLIdentifier($0)) })
    }

    /// Specify a list of columns to be returned as the result of the query.
    ///
    /// - Returns: A ``SQLReturningResultBuilder`` which must be used to execute the query.
    @inlinable
    public func returning(_ columns: any SQLExpression...) -> SQLReturningResultBuilder<Self> {
        self.returning(columns)
    }

    /// Specify a list of columns to be returned as the result of the query.
    ///
    /// - Returns: A ``SQLReturningResultBuilder`` which must be used to execute the query.
    @inlinable
    public func returning(_ columns: [any SQLExpression]) -> SQLReturningResultBuilder<Self> {
        self.returning = .init(columns)
        return SQLReturningResultBuilder(self)
    }
}

/// A builder returned from the methods of ``SQLReturningBuilder``; this builder wraps the original
/// builder with one which provides ``SQLQueryFetcher`` conformance. As such, the
/// ``SQLReturningBuilder/returning(_:)-84avj`` methods must always be the last ones in any call chain.
///
/// Example:
///
///     // Correct:
///     db.insert(into: "foo").model(foo).returning("id").first() // Returns a row containing an "id" column
///
///     // Incorrect:
///     db.insert(into: "foo").returning("id").model(foo).first() // Syntax error
///
/// > Note: The only reason we can't make ``SQLReturningResultBuilder`` conditionally conform to the
/// > other builder protocols and thus remove the "last-in-chain" restriction is that it has historically
/// > exposed its ``query`` and ``database`` properties as both mutable and public, whereas they are
/// > get-only in the ``SQLQueryBuilder`` protocol - a classic example of [Hyrum's Law](https://hyrumslaw.com)
/// > and its consequences. Conforming ``SQLReturningBuilder`` directly to ``SQLQueryFetcher`` would have been
/// > a simpler approach, but then the availability of the fetching methods would not have been contingent upon
/// > the presence of a returning clause.
public final class SQLReturningResultBuilder<QueryBuilder: SQLReturningBuilder>: SQLQueryFetcher {
    // See `SQLQueryBuilder.query`.
    public var query: any SQLExpression
    
    // See `SQLQueryBuilder.database`.
    public var database: any SQLDatabase
    
    /// Create a new last-in-chain fetching query wrapper.
    @usableFromInline
    init(_ builder: QueryBuilder) {
        self.query = builder.query
        self.database = builder.database
    }
}
