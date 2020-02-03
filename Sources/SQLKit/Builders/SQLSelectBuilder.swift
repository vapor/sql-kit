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
    
    public func distinct() -> Self {
        self.select.isDistinct = true
        return self
    }
    
    public func distinct(on collumns: String...) -> Self {
        self.select.isDistinct = true
        self.select.columns = []
        collumns.forEach { _ = self.column($0) }
        return self
    }
    
    public func distinct(on collumns: SQLExpression...) -> Self {
        self.select.isDistinct = true
        self.select.columns = collumns
        return self
    }
    
    public func column(_ column: String) -> Self {
        if column == "*" {
            return self.column(SQLLiteral.all)
        } else {
            return self.column(SQLIdentifier(column))
        }
    }
    
    public func column(table: String, column: String) -> Self {
        return self.column(SQLColumn(SQLIdentifier(column), table: SQLIdentifier(table)))
    }
    
    public func column(_ expr: SQLExpression) -> Self {
        self.select.columns.append(expr)
        return self
    }
    
    public func from(_ table: String) -> Self {
        return self.from(SQLIdentifier(table))
    }
    
    public func from(_ table: SQLIdentifier) -> Self {
        self.select.tables.append(table)
        return self
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
