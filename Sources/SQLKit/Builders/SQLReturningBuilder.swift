public protocol SQLReturningBuilder: SQLQueryBuilder {
    var returning: SQLReturning? { get set }
}

extension SQLReturningBuilder {
    /// Specify a list of columns to be part of the result set of the query.
    /// Each provided name is a string assumed to be a valid SQL identifier and
    /// is not qualified.
    ///
    /// - parameters:
    ///     - columns: The names of the columns to return.
    /// - returns: `SQLReturningResultBuilder` to complete the chain.
    public func returning(_ columns: String...) -> SQLReturningResultBuilder<Self> {
        let sqlColumns = columns.map { (column) -> SQLColumn in
            if column == "*" {
                return SQLColumn(SQLLiteral.all)
            } else {
                return SQLColumn(column)
            }
        }

        self.returning = .init(sqlColumns)
        return SQLReturningResultBuilder(self)
    }

    /// Specify a list of columns to be returned as the result of the query.
    /// Each input is an arbitrary expression.
    ///
    /// - parameters:
    ///     - columns: A list of expressions identifying the columns to return.
    /// - returns: `SQLReturningResultBuilder` to complete the chain.
    public func returning(_ columns: SQLExpression...) -> SQLReturningResultBuilder<Self> {
        self.returning = .init(columns)
        return SQLReturningResultBuilder(self)
    }

    /// Specify a list of columns to be returned as the result of the query.
    /// Each input is an arbitrary expression.
    ///
    /// - parameters:
    ///     - column: An array of expressions identifying the columns to return.
    /// - returns: `SQLReturningResultBuilder` to complete the chain.
    public func returning(_ columns: [SQLExpression]) -> SQLReturningResultBuilder<Self> {
        self.returning = .init(columns)
        return SQLReturningResultBuilder(self)
    }
}

/// Return type from `SQLReturningBuilder` methods which allows `SQLQueryFetcher` calls
/// such as `first()` and `all()`. Therefore `returning(...)` must be the second last method
/// in the query chain.
public final class SQLReturningResultBuilder<QueryBuilder: SQLQueryBuilder>: SQLQueryFetcher {
    public var query: SQLExpression
    public var database: SQLDatabase

    init(_ builder: QueryBuilder) {
        query = builder.query
        database = builder.database
    }
}
