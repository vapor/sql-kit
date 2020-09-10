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

// MARK: Switch

extension SQLSelectBuilder {
    private func lastCase(_ closure: (inout SQLCaseExpression) -> ()) {
        guard let index = self.select.columns.lastIndex(where: { $0 as? SQLCaseExpression != nil }) else {
            return
        }
        guard var expression = self.select.columns[index] as? SQLCaseExpression else {
            return
        }

        closure(&expression)
        self.select.columns[index] = expression
    }


    // MARK: Case

    /// Specify a new `SELECT CASE` statement without a base predicate.
    ///
    /// This method is used when the predicates should exist in the `WHEN` clauses instead, i.e.
    ///
    /// ```sql
    /// CASE WHEN COUNT(table.id) > 0 THEN 'Not Empty' ELSE 'Empty' END
    /// ```
    public func `case`() -> Self {
        return self.case(nil)
    }

    /// Specify a new `SELECT CASE` statement with a value to switch over
    ///
    ///     builder.case(42)
    ///
    /// This method probably only exists for completeness sake, but maybe someone will find it useful. 🐐
    ///
    /// - Parameters:
    ///   - value: The value ti switch over the the case's `WHEN` statements.
    public func `case`<E>(_ value: E) -> Self
        where E: Encodable
    {
        return self.case(SQLBind(value))
    }


    /// Specify a new `SELECT CASE` statement with a column to switch over
    ///
    ///     builder.case("address_type")
    ///
    /// - Parameters:
    ///   - identifier: The identifier for the column to switch over in the `CASE` statement.
    public func `case`(_ identifier: SQLIdentifier) -> Self {
        return self.case(identifier as SQLExpression)
    }

    /// Specify a new `SELECT CASE` statement with a base predicate.
    ///
    ///     builder.case("address_type", .in, ["residental", "buisness"])
    ///
    /// - Parameters:
    ///   - left: The column identifier to match a value against.
    ///   - operator: The operator used to check if the column and value match.
    ///   - value: The value that the identified column should contain. This value is an array in this case.
    public func `case`<E>(_ identifier: SQLIdentifier, _ operator: SQLBinaryOperator, _ value: [E]) -> Self
        where E: Encodable
    {
        return self.case(identifier, `operator`, SQLBind.group(value))
    }

    /// Specify a new `SELECT CASE` statement with a base predicate.
    ///
    ///     builder.case("address_type", .equal, "residential")
    ///
    /// - Parameters:
    ///   - left: The column identifier to match a value against.
    ///   - operator: The operator used to check if the column and value match.
    ///   - value: The value that the identified column should contain.
    public func `case`<E>(_ identifier: SQLIdentifier, _ operator: SQLBinaryOperator, _ value: E) -> Self
        where E: Encodable
    {
        return self.case(identifier, `operator`, SQLBind(value))
    }

    /// Specify a new `SELECT CASE` statement with a base predicate.
    ///
    ///     builder.case(SQLFunction("COUNT", args: SQLIdentifier("id")), .equal, SQLLiteral.numeric("1"))
    ///
    /// - Parameters:
    ///   - left: The left expression in the `CASE` matching clause.
    ///   - operator: The operator used to check if the two expressions match or not.
    ///   - right: The right expression in the `CASE` matching clause.
    public func `case`(_ left: SQLExpression, _ operator: SQLBinaryOperator, _ right: SQLExpression) -> Self {
        return self.case(left, `operator` as SQLExpression, right)
    }

    /// Specify a new `SELECT CASE` statement with a base predicate.
    ///
    ///     builder.case(SQLFunction("COUNT", args: SQLIdentifier("id")), SQLBinaryOperator.equal, SQLLiteral.numeric("1"))
    ///
    /// - Parameters:
    ///   - left: The left expression in the `CASE` matching clause.
    ///   - operator: The operator used to check if the two expressions match or not.
    ///   - right: The right expression in the `CASE` matching clause.
    public func `case`(_ left: SQLExpression, _ operator: SQLExpression, _ right: SQLExpression) -> Self {
        return self.case(SQLBinaryExpression(left: left, op: `operator`, right: right))
    }

    /// Specify a new `SELECT CASE` statement with an optional base predicate.
    ///
    /// - Parameter expression: The expression value to switch over in the subsequent `WHEN` statements.
    public func `case`(_ expression: SQLExpression?) -> Self {
        self.select.columns.append(SQLCaseExpression(expression, when: [], else: nil))
        return self
    }

    // MARK: When

    /// Add a `WHEN` clause to the most recent `CASE` statement added to the builder.
    ///
    /// Checks the `CASE` predicate expression against a value, and returns a value if it matches.
    ///
    ///     builder.case("address_type").when(AddressType.residential, then: "House/Apartment")
    ///
    /// - Parameters:
    ///   - match: The value to check against the `CASE` predicate.
    ///   - result: The value to return if the `match` value matches the `CASE` predicate.
    public func when<P, E>(_ match: P, then result: E) -> Self
        where P: Encodable, E: Encodable
    {
        return self.when(SQLBind(match), then: SQLBind(result))
    }

    /// Add a `WHEN` clause to the most recent `CASE` statement added to the builder.
    ///
    /// Checks the predicate passed in and returns a value if it is true.
    ///
    ///     builder.case().when("address_type", .equal, AddressType.residential, then: "House/Apartment")
    ///
    /// - Parameters:
    ///   - identifier: The column who's value to check in the predicate.
    ///   - operator: The operator in the predicate used to match the column and value.
    ///   - value: The value to check against the given column in the predicate.
    ///   - result: The value to return from the `CASE` statement if the predicate is true.
    public func when<E, R>(
        _ identifier: SQLIdentifier, _ operator: SQLBinaryOperator, _ value: E,
        then result: R
    ) -> Self
        where E: Encodable, R: Encodable
    {
        return self.when(identifier, `operator`, SQLBind(value), then: SQLBind(value))
    }

    /// Add a `WHEN` clause to the most recent `CASE` statement added to the builder.
    ///
    /// Checks the predicate passed in and returns a column's value if it is true.
    ///
    ///     builder.case().when("address_type", .equal, AddressType.residential, then: "street")
    ///
    /// - Parameters:
    ///   - identifier: The column who's value to check in the predicate.
    ///   - operator: The operator in the predicate used to match the column and value.
    ///   - value: The value to check against the given column in the predicate.
    ///   - result: The column to return the value from if the predicate is true.
    public func when<E>(
        _ identifier: SQLIdentifier, _ operator: SQLBinaryOperator, _ value: E,
        then result: SQLIdentifier
    ) -> Self
        where E: Encodable
    {
        return self.when(identifier, `operator`, SQLBind(value), then: result)
    }

    /// Add a `WHEN` clause to the most recent `CASE` statement added to the builder.
    ///
    /// Checks the predicate passed in and returns a column's value if it is true.
    ///
    ///     builder.case().when(
    ///         SQLIdentifier("address_type"), .equal, SQLBind(AddressType.residential),
    ///         then: SQLLiteral.string("House/Apartment")
    ///     )
    ///
    /// - Parameters:
    ///   - left: The left expression of the `WHEN` clause matching predicate.
    ///   - operator: The operator in the predicate used to match the left and right expressions.
    ///   - right: The right expression of the `WHEN` clause matching predicate.
    ///   - result: The expression to return from the `CASE` statement if the predicate is true.
    public func when(
        _ left: SQLExpression, _ operator: SQLBinaryOperator, _ right: SQLExpression,
        then result: SQLExpression
    ) -> Self {
        return self.when(left, `operator` as SQLExpression, right, then: result)
    }

    /// Add a `WHEN` clause to the most recent `CASE` statement added to the builder.
    ///
    /// Checks the predicate passed in and returns a column's value if it is true.
    ///
    ///     builder.case().when(
    ///         SQLIdentifier("address_type"), SQLBinaryOperator.equal, SQLBind(AddressType.residential),
    ///         then: SQLLiteral.string("House/Apartment")
    ///     )
    ///
    /// - Parameters:
    ///   - left: The left expression of the `WHEN` clause matching predicate.
    ///   - operator: The operator in the predicate used to match the left and right expressions.
    ///   - right: The right expression of the `WHEN` clause matching predicate.
    ///   - result: The expression to return from the `CASE` statement if the predicate is true.
    public func when(
        _ left: SQLExpression, _ operator: SQLExpression, _ right: SQLExpression,
        then result: SQLExpression
    ) -> Self {
        return self.when(SQLBinaryExpression(left: left, op: `operator`, right: right), then: result)
    }

    /// Add a `WHEN` clause to the most recent `CASE` statement added to the builder.
    ///
    /// Checks the predicate passed in and returns a column's value if it is true.
    ///
    ///     builder.case().when(
    ///         SQLBinaryExpression(
    ///             left: SQLIdentifier("address_type"),
    ///             op: SQLBinaryOperator.equal,
    ///             right: SQLBind(AddressType.residential)
    ///         ),
    ///         then: SQLLiteral.string("House/Apartment")
    ///     )
    ///
    /// - Parameters:
    ///   - predicate: The predicate to check for the `WHEN` clause.
    ///   - result: The expression to return from the `CASE` statement if the predicate is true.
    public func when(_ predicate: SQLExpression, then result: SQLExpression) -> Self {
        self.lastCase { $0.cases.append((predicate, result)) }
        return self
    }

    // MARK: Else

    /// Sets the value that the `CASE` clause will return if none of the `WHEN` statements match.
    ///
    /// - Parameter value: The value that the `CASE` statement should return.
    public func `else`<E>(_ value: E) -> Self
        where E: Encodable
    {
        return self.else(SQLBind(value))
    }

    /// Sets the column that the value returned from the `CASE` statement will come from if
    /// none of the `WHEN` predicates pass.
    ///
    /// - Parameter identifier: The column name to return from the `CASE` statement.
    public func `else`(_ identifier: SQLIdentifier) -> Self {
        return self.else(identifier as SQLExpression)
    }

    /// Sets the result of the `CASE` statement if none of the `WHERE` caluse predicates pass.
    ///
    /// - Parameter expression: The fallback return value of the `CASE` statement.
    public func `else`(_ expression: SQLExpression) -> Self {
        self.lastCase { $0.alternative = expression }
        return self
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
