/// Builds `SQLExpression` predicates, i.e., `WHERE` clauses.
///
///     builder.where(\Planet.name == "Earth")
///
/// Expressions will be added using `AND` logic by default. Use `orWhere` to join via `OR` logic.
///
///     builder.where(\Planet.name == "Earth").orWhere(\Planet.name == "Mars")
///
/// See `SQLPredicateGroupBuilder` for building expression groups.
public protocol SQLPredicateBuilder: class {
    /// Expression being built.
    var predicate: SQLExpression? { get set }
}

extension SQLPredicateBuilder {
    /// Adds a column to column comparison to this builder's `WHERE` clause by `AND`ing.
    ///
    ///     builder.where("firstName", .equal, column: "lastName")
    ///
    /// This method compares two _columns_.
    ///
    ///     SELECT * FROM users WHERE firstName = lastName
    ///
    /// - parameters:
    ///     - lhs: Left-hand side column name.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side column name.
    public func `where`(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, column rhs: SQLIdentifier) -> Self {
        self.where(lhs, op, rhs)
    }

    /// Adds a column to encodable comparison to this builder's `WHERE` clause by `AND`ing.
    ///
    ///     builder.where("name", .equal, "Earth")
    ///
    /// The encodable value supplied will be bound to the query as a parameter.
    ///
    ///     SELECT * FROM planets WHERE name = ? // Earth
    ///
    /// - parameters:
    ///     - lhs: Left-hand side column name.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Encodable value.
    /// - returns: Self for chaining.
    public func `where`<E>(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, _ rhs: E) -> Self
        where E: Encodable
    {
        return self.where(lhs, op, SQLBind(rhs))
    }

    /// Adds a column to encodable comparison to this builder's `WHERE` clause by `AND`ing.
    ///
    ///     builder.where("name", .in, ["Earth", "Mars"])
    ///
    /// The encodable value supplied will be bound to the query as a parameter.
    ///
    ///     SELECT * FROM planets WHERE name = ? // Earth
    ///
    /// - parameters:
    ///     - lhs: Left-hand side column name.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Encodable value.
    /// - returns: Self for chaining.
    public func `where`<E>(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, _ rhs: [E]) -> Self
        where E: Encodable
    {
        self.where(lhs, op, SQLBind.group(rhs))
    }

    /// Adds a column to expression comparison to the `WHERE` clause by `AND`ing.
    ///
    ///     builder.where(SQLIdentifier("name"), .equal, SQLBind("Earth"))
    ///
    /// - parameters:
    ///     - lhs: Left-hand side column name.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side expression.
    public func `where`(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, _ rhs: SQLExpression) -> Self {
        self.where(lhs, op as SQLExpression, rhs)
    }

    /// Adds a column to expression comparison to the `WHERE` clause by `AND`ing.
    ///
    ///     builder.where(SQLIdentifier("name"), .equal, SQLBind("Earth"))
    ///
    /// - parameters:
    ///     - lhs: Left-hand side column name.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side expression.
    public func `where`(_ lhs: SQLExpression, _ op: SQLBinaryOperator, _ rhs: SQLExpression) -> Self {
        self.where(lhs, op as SQLExpression, rhs)
    }

    /// Adds an expression to expression comparison, with an arbitrary
    /// expression as operator, to the `WHERE` clause by `AND`ing.
    ///
    ///     builder.where(SQLIdentifier("name"), SQLBinaryOperator.equal, SQLBind("Earth"))
    ///
    /// - parameters:
    ///     - lhs: Left-hand side expression.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side expression.
    /// - returns: Self for chaining.
    public func `where`(_ lhs: SQLExpression, _ op: SQLExpression, _ rhs: SQLExpression) -> Self {
        self.where(SQLBinaryExpression(left: lhs, op: op, right: rhs))
    }

    /// Adds an expression to the `WHERE` clause by `AND`ing.
    ///
    ///     builder.where(.binary("name", .notEqual, .literal(.null)))
    ///
    /// - parameters:
    ///     - expression: Expression to be added to the predicate.
    public func `where`(_ expression: SQLExpression) -> Self {
        if let existing = self.predicate {
            self.predicate = SQLBinaryExpression(
                left: existing,
                op: SQLBinaryOperator.and,
                right: expression
            )
        } else {
            self.predicate = expression
        }
        return self
    }

    /// Adds a column to expression comparison to the `WHERE` clause by `OR`ing.
    ///
    ///     builder.orWhere("name", .equal, .value("Earth"))
    ///
    /// - parameters:
    ///     - lhs: Left-hand side column name.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side expression.
    public func orWhere(_ lhs: String, _ op: SQLBinaryOperator, _ rhs: SQLExpression) -> Self {
        return self.orWhere(SQLIdentifier(lhs), op, rhs)
    }

    /// Adds an expression to expression comparison to the `WHERE` clause by `OR`ing.
    ///
    ///     builder.orWhere("name", .equal, .value("Earth"))
    ///
    /// - parameters:
    ///     - lhs: Left-hand side expression.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side expression.
    /// - returns: Self for chaining.
    public func orWhere(_ lhs: SQLExpression, _ op: SQLBinaryOperator, _ rhs: SQLExpression) -> Self {
        return self.orWhere(SQLBinaryExpression(left: lhs, op: op, right: rhs))
    }

    /// Adds an expression to expression comparison, with an arbitrary
    /// expression as operator, to the `WHERE` clause by `OR`ing.
    ///
    ///     builder.orWhere("name", .equal, .value("Earth"))
    ///
    /// - parameters:
    ///     - lhs: Left-hand side expression.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side expression.
    /// - returns: Self for chaining.
    public func orWhere(_ lhs: SQLExpression, _ op: SQLExpression, _ rhs: SQLExpression) -> Self {
        return self.orWhere(SQLBinaryExpression(left: lhs, op: op, right: rhs))
    }

    /// Adds an expression to the `WHERE` clause by `OR`ing.
    ///
    ///     builder.orWhere(.binary("name", .notEqual, .literal(.null)))
    ///
    /// - parameters:
    ///     - expression: Expression to be added to the predicate.
    public func orWhere(_ expression: SQLExpression) -> Self {
        if let existing = self.predicate {
            self.predicate = SQLBinaryExpression(
                left: existing,
                op: SQLBinaryOperator.or,
                right: expression
            )
        } else {
            self.predicate = expression
        }
        return self
    }
}
