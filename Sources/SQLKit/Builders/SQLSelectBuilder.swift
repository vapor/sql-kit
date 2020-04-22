extension SQLDatabase {
    /// Creates a new `SQLSelectBuilder`.
    ///
    ///     db.select()
    ///         .column("*")
    ///         .from("planets"")
    ///         .where("name", .equal, SQLBind("Earth"))
    ///         .all()
    ///
    public func select() -> SQLSelectBuilder {
        return .init(on: self)
    }
}


public final class SQLSelectBuilder: SQLQueryFetcher, SQLQueryBuilder {
    public var query: SQLExpression {
        return self.select
    }
    
    public var select: SQLSelect
    public var database: SQLDatabase
    
    public init(on database: SQLDatabase) {
        self.select = .init()
        self.database = database
    }
}

// MARK: Joins

extension SQLSelectBuilder: SQLJoinBuilder {
    public var joins: [SQLExpression] {
        get { self.select.joins }
        set { self.select.joins = newValue }
    }
}

// MARK: Predicate

extension SQLSelectBuilder: SQLPredicateBuilder {
    public var predicate: SQLExpression? {
        get { return self.select.predicate }
        set { self.select.predicate = newValue }
    }
}

// MARK: Distinct

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

// MARK: Columns

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

// MARK: From

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

// MARK: Having

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

// MARK: Limit / Offset

extension SQLSelectBuilder {
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

// MARK: Group By

extension SQLSelectBuilder {
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
}


// MARK: Locking

extension SQLSelectBuilder {
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
}
