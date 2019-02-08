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
    /// Adds an expression to the `WHERE` clause.
    ///
    ///     builder.where("name", .equal, "Earth")
    ///
    public func `where`(_ lhs: String, _ op: SQLBinaryOperator, column rhs: String) -> Self {
        return self.where(SQLIdentifier(lhs), op, SQLIdentifier(rhs))
    }
    
    /// Adds an expression to the `WHERE` clause.
    ///
    ///     builder.where("name", .equal, "Earth")
    ///
    public func `where`(_ lhs: String, _ op: SQLBinaryOperator, _ rhs: Encodable) -> Self {
        return self.where(SQLIdentifier(lhs), op, SQLBind(rhs))
    }
    
    /// Adds an expression to the `WHERE` clause.
    ///
    ///     builder.where(.column("name"), .equal, .value("Earth"))
    ///
    public func `where`(_ lhs: String, _ op: SQLBinaryOperator, _ rhs: SQLExpression) -> Self {
        return self.where(SQLIdentifier(lhs), op, rhs)
    }
    
    /// Adds an expression to the `WHERE` clause.
    ///
    ///     builder.where(.column("name"), .equal, .value("Earth"))
    ///
    public func `where`(_ lhs: SQLExpression, _ op: SQLBinaryOperator, _ rhs: SQLExpression) -> Self {
        return self.where(SQLBinaryExpression(left: lhs, op: op, right: rhs))
    }
    
    /// Adds an expression to the `WHERE` clause.
    ///
    ///     builder.where(.column("name"), .equal, .value("Earth"))
    ///
    public func `where`(_ lhs: SQLExpression, _ op: SQLExpression, _ rhs: SQLExpression) -> Self {
        return self.where(SQLBinaryExpression(left: lhs, op: op, right: rhs))
    }

    /// Adds an expression to the `WHERE` clause.
    ///
    ///     builder.where(.binary("name", .notEqual, .literal(.null)))
    ///
    /// - parameters:
    ///     - expression: Expression to be added via `AND` to the predicate.
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

    /// Adds an expression to the `WHERE` clause.
    ///
    ///     builder.orWhere(.column("name"), .equal, .value("Earth"))
    ///
    public func orWhere(_ lhs: String, _ op: SQLBinaryOperator, _ rhs: SQLExpression) -> Self {
        return self.orWhere(SQLIdentifier(lhs), op, rhs)
    }
    
    /// Adds an expression to the `WHERE` clause.
    ///
    ///     builder.orWhere(.column("name"), .equal, .value("Earth"))
    ///
    public func orWhere(_ lhs: SQLExpression, _ op: SQLBinaryOperator, _ rhs: SQLExpression) -> Self {
        return self.orWhere(SQLBinaryExpression(left: lhs, op: op, right: rhs))
    }
    
    /// Adds an expression to the `WHERE` clause.
    ///
    ///     builder.orWhere(.column("name"), .equal, .value("Earth"))
    ///
    public func orWhere(_ lhs: SQLExpression, _ op: SQLExpression, _ rhs: SQLExpression) -> Self {
        return self.orWhere(SQLBinaryExpression(left: lhs, op: op, right: rhs))
    }
    
    /// Adds an expression to the `WHERE` clause.
    ///
    ///     builder.orWhere(.binary("name", .notEqual, .literal(.null)))
    ///
    /// - parameters:
    ///     - expression: Expression to be added via `AND` to the predicate.
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
