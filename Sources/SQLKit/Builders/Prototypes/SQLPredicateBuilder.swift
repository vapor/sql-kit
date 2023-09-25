/// Common definitions for any query builder which permits specifying a primary predicate.
///
///     builder.where("name", .equal, "Earth")
///
/// Expressions specified with ``where(_:)`` are considered conjunctive (`AND`).
/// Expressions specified with ``orWhere(_:)`` are considered inclusively disjunctive (`OR`).
/// See ``SQLPredicateGroupBuilder`` for details of grouping expressions (i.e. with parenthesis).
public protocol SQLPredicateBuilder: AnyObject {
    /// Expression being built.
    var predicate: (any SQLExpression)? { get set }
}

extension SQLPredicateBuilder {
    /// Adds a column to column comparison to this builder's `WHERE` clause by `AND`ing.
    ///
    ///     builder.where("firstName", .equal, column: "lastName")
    ///
    /// This method compares two _columns_.
    ///
    ///     SELECT * FROM "users" WHERE "firstName" = "lastName"
    @inlinable
    @discardableResult
    public func `where`(_ lhs: String, _ op: SQLBinaryOperator, column rhs: String) -> Self {
        self.where(SQLColumn(lhs), op, SQLColumn(rhs))
    }

    /// Adds a column to column comparison to this builder's `WHERE` clause by `AND`ing.
    ///
    ///     builder.where("firstName", .equal, column: "lastName")
    ///
    /// This method compares two _columns_.
    ///
    ///     SELECT * FROM "users" WHERE "firstName" = "lastName"
    @inlinable
    @discardableResult
    public func `where`(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, column rhs: SQLIdentifier) -> Self {
        self.where(SQLColumn(lhs), op, SQLColumn(rhs))
    }

    /// Adds a column to encodable comparison to this builder's `WHERE` clause by `AND`ing.
    ///
    ///     builder.where("name", .equal, "Earth")
    ///
    /// The encodable value supplied will be bound to the query as a parameter.
    ///
    ///     SELECT * FROM "planets" WHERE "name" = $0 ["Earth"]
    @inlinable
    @discardableResult
    public func `where`<E: Encodable>(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, _ rhs: E) -> Self { // TODO: Use `some Encodable` when possible.
        self.where(SQLColumn(lhs), op, SQLBind(rhs))
    }

    /// Adds a column to encodable array comparison to this builder's `WHERE` clause by `AND`ing.
    ///
    ///     builder.where("name", .in, ["Earth", "Mars"])
    ///
    /// The encodable values supplied will be bound to the query as parameters.
    ///
    ///     SELECT * FROM "planets" WHERE "name" IN ($0, $1) ["Earth", "Mars"]
    @inlinable
    @discardableResult
    public func `where`<E: Encodable>(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, _ rhs: [E]) -> Self { // TODO: Use `some Encodable` when possible.
        self.where(SQLColumn(lhs), op, SQLBind.group(rhs))
    }

    /// Adds a column to expression comparison to this builder' `WHERE` clause by `AND`ing.
    @inlinable
    @discardableResult
    public func `where`(_ lhs: String, _ op: SQLBinaryOperator, _ rhs: any SQLExpression) -> Self {
        self.where(SQLColumn(lhs), op, rhs)
    }

    /// Adds a column to expression comparison to this builder's `WHERE` clause by `AND`ing.
    @inlinable
    @discardableResult
    public func `where`(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, _ rhs: any SQLExpression) -> Self {
        self.where(SQLColumn(lhs), op, rhs)
    }

    /// Adds an expression to expression comparison to this builder's `WHERE` clause by `AND`ing.
    @inlinable
    @discardableResult
    public func `where`(_ lhs: any SQLExpression, _ op: SQLBinaryOperator, _ rhs: any SQLExpression) -> Self {
        self.where(lhs, op as any SQLExpression, rhs)
    }

    /// Adds an expression to expression comparison with arbitrary operator expression to this
    /// builder's `WHERE` clause by `AND`ing.
    @inlinable
    @discardableResult
    public func `where`(_ lhs: any SQLExpression, _ op: any SQLExpression, _ rhs: any SQLExpression) -> Self {
        self.where(SQLBinaryExpression(left: lhs, op: op, right: rhs))
    }

    /// Adds an expression to this builder's `WHERE` clause by `AND`ing.
    @inlinable
    @discardableResult
    public func `where`(_ expression: any SQLExpression) -> Self {
        if let existing = self.predicate {
            self.predicate = SQLBinaryExpression(left: existing, op: SQLBinaryOperator.and, right: expression)
        } else {
            self.predicate = expression
        }
        return self
    }
}

extension SQLPredicateBuilder {
    /// Adds a column to column comparison to this builder's `WHERE` clause by `OR`ing.
    ///
    ///     builder.where(SQLLiteral.boolean(false)).orWhere("firstName", .equal, column: "lastName")
    ///
    /// This method compares two _columns_.
    ///
    ///     SELECT * FROM "users" WHERE 0 OR "firstName" = "lastName"
    @inlinable
    @discardableResult
    public func orWhere(_ lhs: String, _ op: SQLBinaryOperator, column rhs: String) -> Self {
        self.orWhere(SQLColumn(lhs), op, SQLColumn(rhs))
    }

    /// Adds a column to column comparison to this builder's `WHERE` clause by `OR`ing.
    @inlinable
    @discardableResult
    public func orWhere(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, column rhs: SQLIdentifier) -> Self {
        self.orWhere(SQLColumn(lhs), op, SQLColumn(rhs))
    }
    
    /// Adds a column to encodable comparison to this builder's `WHERE` clause by `OR`ing.
    @inlinable
    @discardableResult
    public func orWhere<E: Encodable>(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, _ rhs: E) -> Self {
        self.orWhere(SQLColumn(lhs), op, SQLBind(rhs))
    }

    /// Adds a column to encodable array comparison to this builder's `WHERE` clause by `OR`ing.
    @inlinable
    @discardableResult
    public func orWhere<E: Encodable>(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, _ rhs: [E]) -> Self {
        self.orWhere(SQLColumn(lhs), op, SQLBind.group(rhs))
    }

    /// Adds a column to expression comparison to the `WHERE` clause by `OR`ing.
    @inlinable
    @discardableResult
    public func orWhere(_ lhs: String, _ op: SQLBinaryOperator, _ rhs: any SQLExpression) -> Self {
        self.orWhere(SQLIdentifier(lhs), op, rhs)
    }
    
    /// Adds a column to expression comparison to the `WHERE` clause by `OR`ing.
    @inlinable
    @discardableResult
    public func orWhere(_ lhs: SQLIdentifier, _ op: SQLBinaryOperator, _ rhs: any SQLExpression) -> Self {
        self.orWhere(SQLColumn(lhs), op, rhs)
    }

    /// Adds an expression to expression comparison to this builder's `WHERE` clause by `OR`ing.
    @inlinable
    @discardableResult
    public func orWhere(_ lhs: any SQLExpression, _ op: SQLBinaryOperator, _ rhs: any SQLExpression) -> Self {
        self.orWhere(lhs, op as any SQLExpression, rhs)
    }

    /// Adds an expression to expression comparison with arbitrary operator expression to this
    /// builder's `WHERE` clause by `OR`ing.
    @inlinable
    @discardableResult
    public func orWhere(_ lhs: any SQLExpression, _ op: any SQLExpression, _ rhs: any SQLExpression) -> Self {
        self.orWhere(SQLBinaryExpression(left: lhs, op: op, right: rhs))
    }

    /// Adds an expression to this builder's `WHERE` clause by `OR`ing.
    @inlinable
    @discardableResult
    public func orWhere(_ expression: any SQLExpression) -> Self {
        if let existing = self.predicate {
            self.predicate = SQLBinaryExpression(left: existing, op: SQLBinaryOperator.or, right: expression)
        } else {
            self.predicate = expression
        }
        return self
    }
}
