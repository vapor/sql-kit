extension SQLAliasedColumnListBuilder {
    /// Specify a column qualified with a table name to be part of the result set of the query.
    ///
    /// This method is deprecated. Use ``SQLColumn/init(_:table:)-19zso`` or ``SQLColumn/init(_:table:)-77d24`` instead.
    @inlinable
    @discardableResult
    @available(*, deprecated, renamed: "SQLColumn.init(_:table:)", message: "Use ``SQLColumn.init(_:table:)`` instead.")
    public func column(table: String, column: String) -> Self {
        self.column(SQLColumn(column, table: table))
    }
}

/// Formerly a separate builder used to construct `SELECT` subqueries in `CREATE TABLE` queries, now a deprecated
/// alias for the more general-purpose ``SQLSubqueryBuilder``.
@available(*, deprecated, renamed: "SQLSubqueryBuilder", message: "Superseded by SQLSubqueryBuilder")
public typealias SQLCreateTableAsSubqueryBuilder = SQLSubqueryBuilder

extension SQLCreateTriggerBuilder {
    /// Specify a conditional expression which determines whether the trigger is actually executed.
    @available(*, deprecated, message: "Specifying conditions as raw strings is unsafe. Use `SQLBinaryExpression` etc. instead.")
    @inlinable
    @discardableResult
    public func condition(_ value: String) -> Self {
        self.condition(SQLRaw(value))
    }

    /// Specify a body for the trigger.
    @available(*, deprecated, message: "Specifying SQL statements as raw strings is unsafe. Use `SQLQueryString` or `SQLRaw` explicitly.")
    @inlinable
    @discardableResult
    public func body(_ statements: [String]) -> Self {
        self.body(statements.map { SQLRaw($0) })
    }
}

extension SQLJoinBuilder {
    /// Include the given table in the list of those used by the query, performing an explicit join using the
    /// given method and condition(s). Tables are joined left to right.
    ///
    /// - Parameters:
    ///   - table: The name of the table to join.
    ///   - method: The join method to use.
    ///   - expression: A string containing a join condition.
    @available(*, deprecated, message: "Specifying conditions as raw strings is unsafe. Use `SQLBinaryExpression` etc. instead.")
    @inlinable
    @discardableResult
    public func join(_ table: String, method: SQLJoinMethod = .inner, on expression: String) -> Self {
         self.join(SQLIdentifier(table), method: method, on: SQLRaw(expression))
    }
}
