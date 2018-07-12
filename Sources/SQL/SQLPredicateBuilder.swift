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
    /// See `SQLExpression`.
    associatedtype Expression: SQLExpression
    
    /// Expression being built.
    var predicate: Expression? { get set }
}

extension SQLPredicateBuilder {
    /// Adds an expression to the `WHERE` clause.
    ///
    ///     builder.where(\Planet.name == "Earth")
    ///
    /// - parameters:
    ///     - expression: Expression to be added via `AND` to the predicate.
    public func `where`(_ expression: Expression) -> Self {
        self.predicate &= expression
        return self
    }
    
    /// Adds an expression to the `WHERE` clause.
    ///
    ///     builder.orWhere(\Planet.name == "Earth")
    ///
    /// - parameters:
    ///     - expression: Expression to be added via `OR` to the predicate.
    public func orWhere(_ expression: Expression) -> Self {
        self.predicate |= expression
        return self
    }
    
    /// Adds an expression to the `WHERE` clause.
    ///
    ///     builder.where(.column("name"), .equal, .value("Earth"))
    ///
    public func `where`(_ lhs: Expression, _ op: Expression.BinaryOperator, _ rhs: Expression) -> Self {
        self.predicate &= .binary(lhs, op, rhs)
        return self
    }
    
    /// Adds an expression to the `WHERE` clause.
    ///
    ///     builder.orWhere(.column("name"), .equal, .value("Earth"))
    ///
    public func orWhere(_ lhs: Expression, _ op: Expression.BinaryOperator, _ rhs: Expression) -> Self {
        self.predicate |= .binary(lhs, op, rhs)
        return self
    }
}
