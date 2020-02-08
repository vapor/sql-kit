public final class SQLSelectBuilder: SQLQueryFetcher, SQLQueryBuilder, SQLPredicateBuilder {
    public var query: SQLExpression {
        return self.select
    }
    
    public var predicate: SQLExpression? {
        get { return self.select.predicate }
        set { self.select.predicate = newValue }
    }
    
    public var select: SQLSelect
    public var database: SQLDatabase
    
    
    public init(on database: SQLDatabase) {
        self.select = .init()
        self.database = database
    }
    
    public func limit(_ limit: Int) -> Self {
        self.select.limit = limit
        return self
    }
    
    public func offset(_ offset: Int) -> Self {
        self.select.offset = offset
        return self
    }
    
    /// Adds a `GROUP BY` clause to the select statement.
    ///
    /// - parameters:
    ///     - expression: `SQLExpression` to group by.
    /// - returns: Self for chaining.
    public func groupBy(_ column: String) -> Self {
        return self.groupBy(SQLColumn(column))
    }
    
    /// Adds a `GROUP BY` clause to the select statement.
    ///
    /// - parameters:
    ///     - expression: `SQLExpression` to group by.
    /// - returns: Self for chaining.
    public func groupBy(_ expression: SQLExpression) -> Self {
        self.select.groupBy.append(expression)
        return self
    }
    
    /// Adds an `ORDER BY` clause to the select statement.
    ///
    /// - parameters:
    ///     - expression: `SQLExpression` to order by.
    /// - returns: Self for chaining.
    public func orderBy(_ column: String, _ direction: SQLDirection = .ascending) -> Self {
        return self.orderBy(SQLColumn(column), direction)
    }
    
    
    /// Adds an `ORDER BY` clause to the select statement.
    ///
    /// - parameters:
    ///     - expression: `SQLExpression` to order by.
    /// - returns: Self for chaining.
    public func orderBy(_ expression: SQLExpression, _ direction: SQLExpression) -> Self {
        return self.orderBy(SQLOrderBy(expression: expression, direction: direction))
    }
    
    /// Adds an `ORDER BY` clause to the select statement.
    ///
    /// - parameters:
    ///     - expression: `SQLExpression` to order by.
    /// - returns: Self for chaining.
    public func orderBy(_ expression: SQLExpression) -> Self {
        select.orderBy.append(expression)
        return self
    }
    
    /// Adds a locking expression to this `SELECT` statement.
    ///
    ///     db.select()...for(.update)
    ///
    /// Also called locking reads, the `SELECT ... FOR UPDATE` syntax
    /// will lock all selected rows for the duration of the current transaction.
    /// How the rows are locked depends on the specific expression supplied.
    ///
    /// - parameters:
    ///     - lockingClause: Locking clause type.
    /// - returns: Self for chaining.
    public func `for`(_ lockingClause: SQLLockingClause) -> Self {
        return self.lockingClause(lockingClause)
    }
    
    /// Adds a locking expression to this `SELECT` statement.
    ///
    ///     db.select()...lockingClause(...)
    ///
    /// Also called locking reads, the `SELECT ... FOR UPDATE` syntax
    /// will lock all selected rows for the duration of the current transaction.
    /// How the rows are locked depends on the specific expression supplied.
    ///
    /// - note: This method allows for any `SQLExpression` conforming
    ///         type to be passed as the locking clause.
    ///
    /// - parameters:
    ///     - lockingClause: Locking clause type.
    /// - returns: Self for chaining.
    public func lockingClause(_ lockingClause: SQLExpression) -> Self {
        self.select.lockingClause = lockingClause
        return self
    }
    
    /// Adds a `LIMIT` clause to the select statement.
    ///
    ///     builder.limit(5)
    ///
    /// - parameters:
    ///     - max: Optional maximum limit.
    ///            If `nil`, existing limit will be removed.
    /// - returns: Self for chaining.
    public func limit(_ max: Int?) -> Self {
        self.select.limit = max
        return self
    }
    
    /// Adds a `OFFSET` clause to the select statement.
    ///
    ///     builder.offset(5)
    ///
    /// - parameters:
    ///     - max: Optional offset.
    ///            If `nil`, existing offset will be removed.
    /// - returns: Self for chaining.
    public func offset(_ n: Int?) -> Self {
        self.select.offset = n
        return self
    }
}

/// DISINCT
extension SQLSelectBuilder {
    /// Adds a DISTINCT clause to the select statement.
    ///
    ///     builder.distinct()
    ///
    /// - returns: Self for chaining
    public func distinct() -> Self {
        self.select.isDistinct = true
        return self
    }
    
    /// Adds a DISTINCT clause to the select statement.
    ///
    ///     builder.distinct(on: "my_collumn")
    ///
    /// - returns: Self for chaining
    public func distinct(on columns: String...) -> Self {
        self.select.isDistinct = true
        self.select.columns = []
        columns.forEach { _ = self.column($0) }
        return self
    }
    
    /// Adds a DISTINCT clause to the select statement.
    ///
    ///     builder.distinct(on: SQLRaw("my_collumn"))
    ///
    /// - returns: Self for chaining
    public func distinct(on columns: SQLExpression...) -> Self {
        self.select.isDistinct = true
        self.select.columns = columns
        return self
    }
}

/// Column list
extension SQLSelectBuilder {
    
    /// Specify a column to be part of the result set of the query. The column
    /// is a string assumed to be a valid SQL identifier and is not qualified.
    /// The string "*" (a single asterisk) is recognized and replaced by
    /// `SQLLiteral.all`.
    ///
    /// - Parameter column: The name of the column to return, or "*" for all.
    public func column(_ column: String) -> Self {
        if column == "*" {
            return self.column(SQLLiteral.all)
        } else {
            return self.column(SQLIdentifier(column))
        }
    }
    
    /// Specify a column to be part of the result set of the query. The column
    /// is a string assumed to be a valid SQL identifier and is qualified by a
    /// table name, also a string assumed to be a valid SQL identifier.
    ///
    /// - Parameters:
    ///   - table: The name of a table to qualify the column name.
    ///   - column: The name of the column to return.
    public func column(table: String, column: String) -> Self {
        return self.column(SQLColumn(SQLIdentifier(column), table: SQLIdentifier(table)))
    }
    
    /// Specify a column to be part of the result set of the query. The column
    /// is an arbitrary expression.
    ///
    /// - Parameter expr: An expression identifying the desired data to return.
    public func column(_ expr: SQLExpression) -> Self {
        self.select.columns.append(expr)
        return self
    }
    
    /// Specify a list of columns to be part of the result set of the query.
    /// Each provided name is a string assumed to be a valid SQL identifier and
    /// is not qualified. The string "*" is recognized and replaced by
    /// `SQLLiteral.all`.
    ///
    /// - Parameter columns: The names of the columns to return.
    public func columns(_ columns: String...) -> Self {
        return columns.reduce(self) { $0.column($1) }
    }
    
    /// Specify a list of columns to be part of the result set of the query.
    /// Each provided name is a string assumed to be a valid SQL identifier and
    /// is not qualified. The string "*" is recognized and replaced by
    /// `SQLLiteral.all`.
    ///
    /// - Parameter columns: The names of the columns to return.
    public func columns(_ columns: [String]) -> Self {
        return columns.reduce(self) { $0.column($1) }
    }
    
    /// Specify a list of columns to be part of the result set of the query.
    /// Each input is an arbitrary expression.
    ///
    /// - Parameter columns: A list of expressions identifying the desired data
    ///                      to return.
    public func columns(_ columns: SQLExpression...) -> Self {
        return self.columns(columns)
    }
    
    /// Specify a list of columns to be part of the result set of the query.
    /// Each input is an arbitrary expression.
    ///
    /// - Parameter columns: A list of expressions identifying the desired data
    ///                      to return.
    public func columns(_ columns: [SQLExpression]) -> Self {
        return columns.reduce(self) { $0.column($1) }
    }

}

/// FROM
extension SQLSelectBuilder {

    /// Include the given table in the list of those used by the query, without
    /// performing an explicit join. The table specifier is a string assumed to
    /// be a valid SQL identifier.
    ///
    /// - Parameter table: The name of the table to use.
    public func from(_ table: String) -> Self {
        return self.from(SQLIdentifier(table))
    }
    
    /// Include the given table in the list of those used by the query, without
    /// performing an explicit join. The table specifier may be any expression.
    ///
    /// - Parameters:
    ///   - table: An expression identifying the table to use.
    public func from(_ table: SQLExpression) -> Self {
        self.select.tables.append(table)
        return self
    }
    
    /// Include the given table in the list of those used by the query, without
    /// performing an explicit join. An alias for the table may be provided. The
    /// table and alias specifiers are strings assumed to be valid SQL
    /// identifiers.
    ///
    /// - Parameters:
    ///   - table: The name of the table to use.
    ///   - alias: The alias to use for the table.
    public func from(_ table: String, as alias: String) -> Self {
        return self.from(SQLIdentifier(table), as: SQLIdentifier(alias))
    }
    
    /// Include the given table in the list of those used by the query, without
    /// performing an explicit join. The table and alias specifiers may be
    /// arbitrary expressions.
    ///
    /// - Parameters:
    ///   - table: An expression identifying the table to use.
    ///   - alias: An expression providing the alias to use for the table.
    public func from(_ table: SQLExpression, as alias: SQLExpression) -> Self {
        return self.from(SQLAlias(table, as: alias))
    }

}

/// Joins
extension SQLSelectBuilder {

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
    public func join(_ table: String, method: SQLJoinMethod = .inner, on expression: String) -> Self {
        return self.join(SQLIdentifier(table), method: method, on: SQLRaw(expression))
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
    public func join(_ table: SQLExpression, method: SQLExpression = SQLJoinMethod.inner, on expression: SQLExpression) -> Self {
        self.select.joins.append(SQLJoin(method: method, table: table, expression: expression))
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
    public func join(
        _ table: SQLExpression,
        method: SQLExpression = SQLJoinMethod.inner,
        on left: SQLExpression,
        _ op: SQLBinaryOperator,
        _ right: SQLExpression
    ) -> Self {
        return self.join(table, method: method, on: SQLBinaryExpression(left: left, op: op, right: right))
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
    public func join(_ table: SQLExpression, method: SQLExpression = SQLJoinMethod.inner, using columns: SQLExpression) -> Self {
        // TODO TODO TODO: Figure out a nice way to make `SQLJoin` aware of the
        // `USING()` syntax; this method is hacky and doesn't respect
        // differences between database drivers.
        self.select.joins.append(SQLList([
            method, SQLRaw("JOIN"), table,
            SQLRaw("USING ("), columns, SQLRaw(")")
        ], separator: SQLRaw(" ")))
        return self
    }
    
}

/// HAVING
extension SQLSelectBuilder {
    /// Adds a column to column comparison to this builder's `HAVING` clause by `AND`ing.
    ///
    ///     builder.having("firstName", .equal, column: "lastName")
    ///
    /// This method compares two _columns_.
    ///
    ///     SELECT * FROM users HAVING firstName = lastName
    ///
    /// - parameters:
    ///     - lhs: Left-hand side column name.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side column name.
    /// - returns: Self for chaining.
    public func having(_ lhs: String, _ op: SQLBinaryOperator, column rhs: String) -> Self {
        return self.having(SQLIdentifier(lhs), op, SQLIdentifier(rhs))
    }

    /// Adds a column to encodable comparison to this builder's `HAVING` clause by `AND`ing.
    ///
    ///     builder.having("name", .equal, "Earth")
    ///
    /// The encodable value supplied will be bound to the query as a parameter.
    ///
    ///     SELECT * FROM planets HAVING name = ? // Earth
    ///
    /// - parameters:
    ///     - lhs: Left-hand side column name.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Encodable value.
    /// - returns: Self for chaining.
    public func having(_ lhs: String, _ op: SQLBinaryOperator, _ rhs: Encodable) -> Self {
        return self.having(SQLIdentifier(lhs), op, SQLBind(rhs))
    }

    /// Adds a column to expression comparison to the `HAVING` clause by `AND`ing.
    ///
    ///     builder.having("name", .equal, .value("Earth"))
    ///
    /// - parameters:
    ///     - lhs: Left-hand side column name.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side expression.
    /// - returns: Self for chaining.
    public func having(_ lhs: String, _ op: SQLBinaryOperator, _ rhs: SQLExpression) -> Self {
        return self.having(SQLIdentifier(lhs), op, rhs)
    }

    /// Adds an expression to expression comparison to the `HAVING` clause by `AND`ing.
    ///
    ///     builder.having("name", .equal, .value("Earth"))
    ///
    /// - parameters:
    ///     - lhs: Left-hand side expression.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side expression.
    /// - returns: Self for chaining.
    public func having(_ lhs: SQLExpression, _ op: SQLBinaryOperator, _ rhs: SQLExpression) -> Self {
        return self.having(SQLBinaryExpression(left: lhs, op: op, right: rhs))
    }

    /// Adds an expression to expression comparison, with an arbitrary
    /// expression as operator, to the `HAVING` clause by `AND`ing.
    ///
    ///     builder.having("name", .equal, .value("Earth"))
    ///
    /// - parameters:
    ///     - lhs: Left-hand side expression.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side expression.
    /// - returns: Self for chaining.
    public func having(_ lhs: SQLExpression, _ op: SQLExpression, _ rhs: SQLExpression) -> Self {
        return self.having(SQLBinaryExpression(left: lhs, op: op, right: rhs))
    }

    /// Adds an expression to the `HAVING` clause by `AND`ing.
    ///
    ///     builder.having(.binary("name", .notEqual, .literal(.null)))
    ///
    /// - parameters:
    ///     - expression: Expression to be added to the predicate.
    public func having(_ expression: SQLExpression) -> Self {
        if let existing = self.select.having {
            self.select.having = SQLBinaryExpression(
                left: existing,
                op: SQLBinaryOperator.and,
                right: expression
            )
        } else {
            self.select.having = expression
        }
        return self
    }

    /// Adds a column to expression comparison to the `HAVING` clause by `OR`ing.
    ///
    ///     builder.orHaving("name", .equal, .value("Earth"))
    ///
    /// - parameters:
    ///     - lhs: Left-hand side column name.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side expression.
    /// - returns: Self for chaining.
    public func orHaving(_ lhs: String, _ op: SQLBinaryOperator, _ rhs: SQLExpression) -> Self {
        return self.orHaving(SQLIdentifier(lhs), op, rhs)
    }

    /// Adds an expression to expression comparison to the `HAVING` clause by `OR`ing.
    ///
    ///     builder.orHaving("name", .equal, .value("Earth"))
    ///
    /// - parameters:
    ///     - lhs: Left-hand side expression.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side expression.
    /// - returns: Self for chaining.
    public func orHaving(_ lhs: SQLExpression, _ op: SQLBinaryOperator, _ rhs: SQLExpression) -> Self {
        return self.orHaving(SQLBinaryExpression(left: lhs, op: op, right: rhs))
    }

    /// Adds an expression to expression comparison, with an arbitrary
    /// expression as operator, to the `HAVING` clause by `OR`ing.
    ///
    ///     builder.orHaving("name", .equal, .value("Earth"))
    ///
    /// - parameters:
    ///     - lhs: Left-hand side expression.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side expression.
    /// - returns: Self for chaining.
    public func orHaving(_ lhs: SQLExpression, _ op: SQLExpression, _ rhs: SQLExpression) -> Self {
        return self.orHaving(SQLBinaryExpression(left: lhs, op: op, right: rhs))
    }

    /// Adds an expression to the `HAVING` clause by `OR`ing.
    ///
    ///     builder.orHaving(.binary("name", .notEqual, .literal(.null)))
    ///
    /// - parameters:
    ///     - expression: Expression to be added to the predicate.
    public func orHaving(_ expression: SQLExpression) -> Self {
        if let existing = self.select.having {
            self.select.having = SQLBinaryExpression(
                left: existing,
                op: SQLBinaryOperator.or,
                right: expression
            )
        } else {
            self.select.having = expression
        }
        return self
    }
}

// MARK: Connection

extension SQLDatabase {
    /// Creates a new `SQLSelectBuilder`.
    ///
    ///     conn.select()
    ///         .column("*")
    ///         .from("planets"")
    ///         .where("name", .equal, SQLBind("Earth"))
    ///         .all()
    ///
    public func select() -> SQLSelectBuilder {
        return .init(on: self)
    }
}
