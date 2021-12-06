/// Builds `SQLExpression` predicates, i.e., `WHERE` clauses.
///
///     builder.where("name", .equal, "Earth")
///
/// Expressions will be added using `AND` logic by default. Use `orWhere` to join via `OR` logic.
///
///     builder.where("name", .equal, "Earth").orWhere("name", .equal, "Mars")
///
/// See `SQLPredicateGroupBuilder` for building expression groups.
public protocol SQLPredicateBuilder: AnyObject {
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
    ///     SELECT * FROM "users" WHERE "firstName" = "lastName"
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column name.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side column name.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func `where`(_ lhs: String, _ op: SQLBinaryOperator, column rhs: String) -> Self {
        return self.where(SQLIdentifier(lhs), op, SQLIdentifier(rhs))
    }

    /// Adds a column to column comparison to this builder's `WHERE` clause by `AND`ing.
    ///
    ///     builder.where("firstName", .equal, column: "lastName")
    ///
    /// This method compares two _columns_.
    ///
    ///     SELECT * FROM "users" WHERE "firstName" = "lastName"
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column name.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side column name.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func `where`(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, column rhs: SQLIdentifier) -> Self {
        return self.where(SQLColumn(lhs), op, SQLColumn(rhs))
    }

    /// Adds a column to encodable comparison to this builder's `WHERE` clause by `AND`ing.
    ///
    ///     builder.where("name", .equal, "Earth")
    ///
    /// The encodable value supplied will be bound to the query as a parameter.
    ///
    ///     SELECT * FROM "planets" WHERE "name" = ? // Earth
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column identifier.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Typed `Encodable` value.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func `where`<E>(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, _ rhs: E) -> Self
        where E: Encodable
    {
        return self.where(SQLColumn(lhs), op, SQLBind(rhs))
    }

    /// Adds a column to encodable array comparison to this builder's `WHERE` clause by `AND`ing.
    ///
    ///     builder.where("name", .in, ["Earth", "Mars"])
    ///
    /// The encodable values supplied will be bound to the query as parameters.
    ///
    ///     SELECT * FROM "planets" WHERE "name" IN (?, ?) // Earth, Mars
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column identifier.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Typed array of `Encodable` values.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func `where`<E>(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, _ rhs: [E]) -> Self
        where E: Encodable
    {
        return self.where(SQLColumn(lhs), op, SQLBind.group(rhs))
    }

    /// Adds a column to expression comparison to this builder' `WHERE` clause by `AND`ing.
    ///
    ///     builder.where("name", .equal, SQLLiteral.string("Earth"))
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column name.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side expression.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func `where`(_ lhs: String, _ op: SQLBinaryOperator, _ rhs: SQLExpression) -> Self {
        return self.where(SQLIdentifier(lhs), op, rhs)
    }

    /// Adds a column to expression comparison to this builder's `WHERE` clause by `AND`ing.
    ///
    ///     builder.where(SQLIdentifier("name"), .equal, SQLBind("Earth"))
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column identifier.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side expression.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func `where`(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, _ rhs: SQLExpression) -> Self {
        return self.where(SQLColumn(lhs), op, rhs)
    }

    /// Adds an expression to expression comparison to this builder's `WHERE` clause by `AND`ing.
    ///
    ///     builder.where(SQLColumn("name"), .equal, SQLBind("Earth"))
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side expression.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side expression.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func `where`(_ lhs: SQLExpression, _ op: SQLBinaryOperator, _ rhs: SQLExpression) -> Self {
        return self.where(lhs, op as SQLExpression, rhs)
    }

    /// Adds an expression to expression comparison with arbitrary operator expression to this
    /// builder's `WHERE` clause by `AND`ing.
    ///
    ///     builder.where(SQLColumn("name"), SQLBinaryOperator.equal, SQLBind("Earth"))
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side expression.
    ///     - op: Operator expression.
    ///     - rhs: Right-hand side expression.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func `where`(_ lhs: SQLExpression, _ op: SQLExpression, _ rhs: SQLExpression) -> Self {
        return self.where(SQLBinaryExpression(left: lhs, op: op, right: rhs))
    }

    /// Adds an expression to this builder's `WHERE` clause by `AND`ing.
    ///
    ///     builder.where(SQLBinaryOperation(SQLColumn("name"), SQLBinaryOperator.notEqual, SQLLiteral.null))
    ///
    /// - Parameter expression: Expression to be added to the predicate.
    /// - Returns: `self` for chaining.
    @discardableResult
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
}

extension SQLPredicateBuilder {
    /// Adds a column to column comparison to this builder's `WHERE` clause by `OR`ing.
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column name.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side column name.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func orWhere(_ lhs: String, _ op: SQLBinaryOperator, column rhs: String) -> Self {
        return self.orWhere(SQLIdentifier(lhs), op, column: SQLIdentifier(rhs))
    }

    /// Adds a column to column comparison to this builder's `WHERE` clause by `OR`ing.
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column identifier.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side column identifier.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func orWhere(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, column rhs: SQLIdentifier) -> Self {
        return self.orWhere(SQLColumn(lhs), op, SQLColumn(rhs))
    }
    
    /// Adds a column to encodable comparison to this builder's `WHERE` clause by `OR`ing.
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column identifier.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Typed `Encodable` value.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func orWhere<E>(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, _ rhs: E) -> Self
        where E: Encodable
    {
        return self.orWhere(SQLColumn(lhs), op, SQLBind(rhs))
    }

    /// Adds a column to encodable array comparison to this builder's `WHERE` clause by `OR`ing.
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column identifier.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Typed array of `Encodable` values.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func orWhere<E>(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, _ rhs: [E]) -> Self
        where E: Encodable
    {
        return self.orWhere(SQLColumn(lhs), op, SQLBind.group(rhs))
    }

    /// Adds a column to expression comparison to the `WHERE` clause by `OR`ing.
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column name.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side expression.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func orWhere(_ lhs: String, _ op: SQLBinaryOperator, _ rhs: SQLExpression) -> Self {
        return self.orWhere(SQLIdentifier(lhs), op, rhs)
    }
    
    /// Adds a column to expression comparison to the `WHERE` clause by `OR`ing.
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side column identifier.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side expression.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func orWhere(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, _ rhs: SQLExpression) -> Self {
        return self.orWhere(SQLColumn(lhs), op, rhs)
    }

    /// Adds an expression to expression comparison to this builder's `WHERE` clause by `OR`ing.
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side expression.
    ///     - op: Binary operator to use for comparison.
    ///     - rhs: Right-hand side expression.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func orWhere(_ lhs: SQLExpression, _ op: SQLBinaryOperator, _ rhs: SQLExpression) -> Self {
        return self.orWhere(lhs, op as SQLExpression, rhs)
    }

    /// Adds an expression to expression comparison with arbitrary operator expression to this
    /// builder's `WHERE` clause by `OR`ing.
    ///
    /// - Parameters:
    ///     - lhs: Left-hand side expression.
    ///     - op: Operator expression.
    ///     - rhs: Right-hand side expression.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func orWhere(_ lhs: SQLExpression, _ op: SQLExpression, _ rhs: SQLExpression) -> Self {
        return self.orWhere(SQLBinaryExpression(left: lhs, op: op, right: rhs))
    }

    /// Adds an expression to this builder's `WHERE` clause by `OR`ing.
    ///
    /// - Parameter expression: Expression to be added to the predicate.
    /// - Returns: `self` for chaining.
    @discardableResult
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
