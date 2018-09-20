@_exported import Async
@_exported import Core
@_exported import DatabaseKit


extension SQLSelectBuilder {
    /// Adds a function expression column to the result set.
    ///
    ///     conn.select()
    ///         .column(function: "count", .all, as: "count")
    ///
    /// - parameters:
    ///     - function: Name of the function to execute.
    ///     - arguments: Zero or more arguments to pass to the function.
    ///                  See `SQLArgument`.
    ///     - alias: Optional alias for the result. This will be the value's
    ///              key in the result set.
    /// - returns: Self for chaining.
    @available(*, deprecated)
    public func column(
        function: String,
        _ arguments: Connection.Query.Select.SelectExpression.Expression.Function.Argument...,
        as alias: Connection.Query.Select.SelectExpression.Identifier? = nil
    ) -> Self {
        return column(.function(.function(function, arguments)), as: alias)
    }
    
    /// Adds an expression column to the result set.
    ///
    ///     conn.select()
    ///         .column(expression: .binary(1, .plus, 1), as: "two")
    ///
    /// - parameters:
    ///     - expression: Expression to resolve.
    ///     - alias: Optional alias for the result. This will be the value's
    ///              key in the result set.
    /// - returns: Self for chaining.
    @available(*, deprecated)
    public func column(
        expression: Connection.Query.Select.SelectExpression.Expression,
        as alias: Connection.Query.Select.SelectExpression.Identifier? = nil
    ) -> Self {
        return column(.expression(expression, alias: alias))
    }
}
