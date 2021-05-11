public protocol SQLJoinBuilder: AnyObject {
    var joins: [SQLExpression] { get set }
}

/// Joins
extension SQLJoinBuilder {
    /// Include the given table in the list of those used by the query,
    /// performing an explicit join using the given method and condition(s).
    /// Tables are joined left to right, in the same order as invocations of
    /// `from()` and `join()`. The table specifier is a string assumed to be a
    /// valid SQL identifier. The condition is a strings assumed to be valid
    /// (semi-))arbitrary SQL. The join method is any `SQLJoinMethod`.
    ///
    /// - Parameters:
    ///   - table: The name of the table to join.
    ///   - method: The join method to use.
    ///   - expression: A string containing a join condition.
    @discardableResult
    public func join(_ table: String, method: SQLJoinMethod = .inner, on expression: String) -> Self {
         self.join(SQLIdentifier(table), method: method, on: SQLRaw(expression))
    }

    /// Include the given table in the list of those used by the query,
    /// performing an explicit join using the given method and condition(s).
    /// Tables are joined left to right, in the same order as invocations of
    /// `from()` and `join()`. The table specifier, condition, and join method
    /// may be arbitrary expressions.
    ///
    /// - Parameters:
    ///   - table: An expression identifying the table to join.
    ///   - method: An expression providing the join method to use.
    ///   - expression: An expression used as the join condition.
    @discardableResult
    public func join(_ table: SQLExpression, method: SQLExpression = SQLJoinMethod.inner, on expression: SQLExpression) -> Self {
        self.joins.append(SQLJoin(method: method, table: table, expression: expression))
        return self
    }

    /// Include the given table in the list of those used by the query,
    /// performing an explicit join using the given method and condition(s).
    /// Tables are joined left to right, in the same order as invocations of
    /// `from()` and `join()`. The table specifier and join method may be
    /// arbitrary expressions. The condition is a triplet of inputs representing
    /// a binary expression.
    ///
    /// - Parameters:
    ///   - table: An expression identifying the table to join.
    ///   - method: An expression providing the join method to use.
    ///   - left: The left side of a binary expression used as a join condition.
    ///   - op: The operator in a binary expression used as a join condition.
    ///   - right: The right side of a binary expression used as a join condition.
    @discardableResult
    public func join(
        _ table: SQLExpression,
        method: SQLExpression = SQLJoinMethod.inner,
        on left: SQLExpression,
        _ op: SQLBinaryOperator,
        _ right: SQLExpression
    ) -> Self {
        self.join(table, method: method, on: SQLBinaryExpression(left: left, op: op, right: right))
    }

    /// Include the given table in the list of those used by the query,
    /// performing an explicit join using the given method and a list of column
    /// names to be used as shorthand join conditions. Tables are joined left to
    /// right, in the same order as invocations of `from()` and `join()`. The
    /// table specifier, column list, and join method may be arbitrary
    /// expressions.
    ///
    /// - Parameters:
    ///   - table: An expression identifying the table to join.
    ///   - method: An expression providing the join method to use.
    ///   - column: An expression giving a list of columns to match between
    ///             the joined tables.
    @discardableResult
    public func join(_ table: SQLExpression, method: SQLExpression = SQLJoinMethod.inner, using columns: SQLExpression) -> Self {
        // TODO TODO TODO: Figure out a nice way to make `SQLJoin` aware of the
        // `USING()` syntax; this method is hacky and doesn't respect
        // differences between database drivers.
        self.joins.append(SQLList([
            method, SQLRaw("JOIN"), table,
            SQLRaw("USING ("), columns, SQLRaw(")")
        ], separator: SQLRaw(" ")))
        return self
    }
}
