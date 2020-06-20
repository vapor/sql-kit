public protocol SQLReturningBuilder: SQLQueryBuilder {
    var returning: SQLReturning? { get set }
}

extension SQLReturningBuilder {
    /// Specify a column to be returned from the query. The column is a
    /// string assumed to be a valid SQL identifier and is not qualified.
    /// The string "*" (a single asterisk) is recognized and replaced by
    /// `SQLLiteral.all`.
    ///
    /// - Parameter column: The name of the column to return, or "*" for all.
    public func returning(_ column: String) -> Self {
        if column == "*" {
            self.returning = .init(SQLColumn(SQLLiteral.all))
        } else {
            self.returning = .init(SQLColumn(column))
        }
        return self
    }

    /// Specify a list of columns to be returned as the result of the query.
    /// Each input is an arbitrary expression.
    ///
    /// - Parameter columns: A list of expressions identifying the desired data
    ///                      to return.
    public func returning(_ columns: SQLExpression...) -> Self {
        self.returning = .init(columns)
        return self
    }

    /// Specify a list of columns to be returned as the result of the query.
    /// Each input is an arbitrary expression.
    ///
    /// - Parameter columns: A list of expressions identifying the desired data
    ///                      to return.
    public func returning(_ columns: [SQLExpression]) -> Self {
        self.returning = .init(columns)
        return self
    }
}
