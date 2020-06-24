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
    /// - returns: Self for chaining.
    public func returning(_ columns: String...) -> Self {
        let sqlColumns = columns.map { (column) -> SQLColumn in
            if column == "*" {
                return SQLColumn(SQLLiteral.all)
            } else {
                return SQLColumn(column)
            }
        }

        self.returning = .init(sqlColumns)
        return self
    }

    /// Specify a list of columns to be returned as the result of the query.
    /// Each input is an arbitrary expression.
    ///
    /// - parameters:
    ///     - columns: A list of expressions identifying the columns to return.
    /// - returns: Self for chaining.
    public func returning(_ columns: SQLExpression...) -> Self {
        self.returning = .init(columns)
        return self
    }

    /// Specify a list of columns to be returned as the result of the query.
    /// Each input is an arbitrary expression.
    ///
    /// - parameters:
    ///     - column: An array of expressions identifying the columns to return.
    /// - returns: Self for chaining.
    public func returning(_ columns: [SQLExpression]) -> Self {
        self.returning = .init(columns)
        return self
    }
}
