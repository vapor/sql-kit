/// Builds secondary `SQLExpression` predicates, i.e., `HAVING` clauses.
///
///     builder.having("name", .equal, "Earth")
///
/// Expressions will be added using `AND` logic by default. Use `orHaving` to join via `OR` logic.
///
///     builder.having("name", .equal, "Earth").orHaving("name", .equal, "Mars")
///
/// See `SQLSecondaryPredicateGroupBuilder` for building expression groups.
public protocol SQLSecondaryPredicateBuilder: AnyObject {
    /// Expression being built.
    var secondaryPredicate: SQLExpression? { get set }
}

extension SQLSecondaryPredicateBuilder {
    /// Adds a column to column comparison to this builder's `HAVING` clause by `AND`ing.
    ///
    ///     builder.having("firstName", .equal, column: "lastName")
    ///
    /// This method compares two _columns_.
    ///
    ///     SELECT * FROM "users" HAVING "firstName" = "lastName"
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column name.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side column name.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func having(_ lhs: String, _ op: SQLBinaryOperator, column rhs: String) -> Self {
        return self.having(SQLIdentifier(lhs), op, SQLIdentifier(rhs))
    }

    /// Adds a column to column comparison to this builder's `HAVING` clause by `AND`ing.
    ///
    ///     builder.having("firstName", .equal, column: "lastName")
    ///
    /// This method compares two _columns_.
    ///
    ///     SELECT * FROM "users" HAVING "firstName" = "lastName"
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column name.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side column name.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func having(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, column rhs: SQLIdentifier) -> Self {
        return self.having(SQLColumn(lhs), op, SQLColumn(rhs))
    }

    /// Adds a column to encodable comparison to this builder's `HAVING` clause by `AND`ing.
    ///
    ///     builder.having("name", .equal, "Earth")
    ///
    /// The encodable value supplied will be bound to the query as a parameter.
    ///
    ///     SELECT * FROM "planets" HAVING "name" = ? // Earth
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column name.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Type-nonspecific `Encodable` value.
    /// - Returns: `self` for chaining.
    @discardableResult
    @_disfavoredOverload // try to prefer the generic version
    public func having(_ lhs: String, _ op: SQLBinaryOperator, _ rhs: Encodable) -> Self {
        return self.having(SQLColumn(lhs), op, SQLBind(rhs))
    }

    /// Adds a column to encodable comparison to this builder's `HAVING` clause by `AND`ing.
    ///
    ///     builder.having("name", .equal, "Earth")
    ///
    /// The encodable value supplied will be bound to the query as a parameter.
    ///
    ///     SELECT * FROM "planets" HAVING "name" = ? // Earth
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column identifier.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Typed `Encodable` value.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func having<E>(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, _ rhs: E) -> Self
        where E: Encodable
    {
        return self.having(SQLColumn(lhs), op, SQLBind(rhs))
    }

    /// Adds a column to encodable array comparison to this builder's `HAVING` clause by `AND`ing.
    ///
    ///     builder.having("name", .in, ["Earth", "Mars"])
    ///
    /// The encodable values supplied will be bound to the query as parameters.
    ///
    ///     SELECT * FROM "planets" HAVING "name" IN (?, ?) // Earth, Mars
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column identifier.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Typed array of `Encodable` values.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func having<E>(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, _ rhs: [E]) -> Self
        where E: Encodable
    {
        return self.having(SQLColumn(lhs), op, SQLBind.group(rhs))
    }

    /// Adds a column to expression comparison to this builder' `HAVING` clause by `AND`ing.
    ///
    ///     builder.having("name", .equal, SQLLiteral.string("Earth"))
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column name.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side expression.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func having(_ lhs: String, _ op: SQLBinaryOperator, _ rhs: SQLExpression) -> Self {
        return self.having(SQLIdentifier(lhs), op, rhs)
    }

    /// Adds a column to expression comparison to this builder's `HAVING` clause by `AND`ing.
    ///
    ///     builder.having(SQLIdentifier("name"), .equal, SQLBind("Earth"))
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column identifier.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side expression.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func having(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, _ rhs: SQLExpression) -> Self {
        return self.having(SQLColumn(lhs), op, rhs)
    }

    /// Adds an expression to expression comparison to this builder's `HAVING` clause by `AND`ing.
    ///
    ///     builder.having(SQLColumn("name"), .equal, SQLBind("Earth"))
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side expression.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side expression.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func having(_ lhs: SQLExpression, _ op: SQLBinaryOperator, _ rhs: SQLExpression) -> Self {
        return self.having(lhs, op as SQLExpression, rhs)
    }

    /// Adds an expression to expression comparison with arbitrary operator expression to this
    /// builder's `HAVING` clause by `AND`ing.
    ///
    ///     builder.having(SQLColumn("name"), SQLBinaryOperator.equal, SQLBind("Earth"))
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side expression.
    ///     - op: Operator expression.
    ///     - rhs: Right-hand side expression.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func having(_ lhs: SQLExpression, _ op: SQLExpression, _ rhs: SQLExpression) -> Self {
        return self.having(SQLBinaryExpression(left: lhs, op: op, right: rhs))
    }

    /// Adds an expression to this builder's `HAVING` clause by `AND`ing.
    ///
    ///     builder.having(SQLBinaryOperation(SQLColumn("name"), SQLBinaryOperator.notEqual, SQLLiteral.null))
    ///
    /// - Parameter expression: Expression to be added to the predicate.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func having(_ expression: SQLExpression) -> Self {
        if let existing = self.secondaryPredicate {
            self.secondaryPredicate = SQLBinaryExpression(
                left: existing,
                op: SQLBinaryOperator.and,
                right: expression
            )
        } else {
            self.secondaryPredicate = expression
        }
        return self
    }
}

extension SQLSecondaryPredicateBuilder {
    /// Adds a column to column comparison to this builder's `HAVING` clause by `OR`ing.
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column name.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side column name.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func orHaving(_ lhs: String, _ op: SQLBinaryOperator, column rhs: String) -> Self {
        return self.orHaving(SQLIdentifier(lhs), op, column: SQLIdentifier(rhs))
    }

    /// Adds a column to column comparison to this builder's `HAVING` clause by `OR`ing.
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column identifier.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side column identifier.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func orHaving(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, column rhs: SQLIdentifier) -> Self {
        return self.orHaving(SQLColumn(lhs), op, SQLColumn(rhs))
    }
    
    /// Adds a column to encodable comparison to this builder's `HAVING` clause by `OR`ing.
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column name.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Type-nonspecific `Encodable` value.
    /// - Returns: Self for chaining.
    @discardableResult
    @_disfavoredOverload // try to prefer the generic version
    public func orHaving(_ lhs: String, _ op: SQLBinaryOperator, _ rhs: Encodable) -> Self {
        return self.orHaving(SQLColumn(lhs), op, SQLBind(rhs))
    }

    /// Adds a column to encodable comparison to this builder's `HAVING` clause by `OR`ing.
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column identifier.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Typed `Encodable` value.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func orHaving<E>(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, _ rhs: E) -> Self
        where E: Encodable
    {
        return self.orHaving(SQLColumn(lhs), op, SQLBind(rhs))
    }

    /// Adds a column to encodable array comparison to this builder's `HAVING` clause by `OR`ing.
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column identifier.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Typed array of `Encodable` values.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func orHaving<E>(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, _ rhs: [E]) -> Self
        where E: Encodable
    {
        return self.orHaving(SQLColumn(lhs), op, SQLBind.group(rhs))
    }

    /// Adds a column to expression comparison to the `HAVING` clause by `OR`ing.
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column name.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side expression.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func orHaving(_ lhs: String, _ op: SQLBinaryOperator, _ rhs: SQLExpression) -> Self {
        return self.orHaving(SQLIdentifier(lhs), op, rhs)
    }
    
    /// Adds a column to expression comparison to the `HAVING` clause by `OR`ing.
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column identifier.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side expression.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func orHaving(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, _ rhs: SQLExpression) -> Self {
        return self.orHaving(SQLColumn(lhs), op, rhs)
    }

    /// Adds an expression to expression comparison to this builder's `HAVING` clause by `OR`ing.
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side expression.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side expression.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func orHaving(_ lhs: SQLExpression, _ op: SQLBinaryOperator, _ rhs: SQLExpression) -> Self {
        return self.orHaving(lhs, op as SQLExpression, rhs)
    }

    /// Adds an expression to expression comparison with arbitrary operator expression to this
    /// builder's `HAVING` clause by `OR`ing.
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side expression.
    ///     - op: Operator expression.
    ///     - rhs: Right-hand side expression.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func orHaving(_ lhs: SQLExpression, _ op: SQLExpression, _ rhs: SQLExpression) -> Self {
        return self.orHaving(SQLBinaryExpression(left: lhs, op: op, right: rhs))
    }

    /// Adds an expression to this builder's `HAVING` clause by `OR`ing.
    ///
    /// - Parameter expression: Expression to be added to the predicate.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func orHaving(_ expression: SQLExpression) -> Self {
        if let existing = self.secondaryPredicate {
            self.secondaryPredicate = SQLBinaryExpression(
                left: existing,
                op: SQLBinaryOperator.or,
                right: expression
            )
        } else {
            self.secondaryPredicate = expression
        }
        return self
    }
}
