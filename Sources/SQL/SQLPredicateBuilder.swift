public protocol SQLPredicateBuilder: class {
    associatedtype Expression: SQLExpression
    var predicate: Expression? { get set }
}

extension SQLPredicateBuilder {
    public func `where`(_ expressions: Expression...) -> Self {
        for expression in expressions {
            self.predicate &= expression
        }
        return self
    }
    
    public func orWhere(_ expressions: Expression...) -> Self {
        for expression in expressions {
            self.predicate |= expression
        }
        return self
    }
    
    public func `where`(_ lhs: Expression, _ op: Expression.BinaryOperator, _ rhs: Expression) -> Self {
        self.predicate &= .binary(lhs, op, rhs)
        return self
    }
    
    public func orWhere(_ lhs: Expression, _ op: Expression.BinaryOperator, _ rhs: Expression) -> Self {
        self.predicate |= .binary(lhs, op, rhs)
        return self
    }
}
