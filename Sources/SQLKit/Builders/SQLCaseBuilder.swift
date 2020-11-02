public final class SQLCaseBuilder {
    public var query: SQLCaseExpression

    public init() {
        self.query = SQLCaseExpression(when: [])
    }
}

extension SQLCaseBuilder {
    public func `case`(_ expression: SQLExpression) -> Self {
        self.query.expression = expression
        return self
    }


    public func `case`(_ literal: SQLLiteral) -> Self {
        return self.case(literal as SQLExpression)
    }

    public func `case`(_ identifier: SQLIdentifier) -> Self {
        return self.case(identifier as SQLExpression)
    }

    public func `case`<E>(_ value: E) -> Self where E: Encodable {
        return self.case(SQLBind(value))
    }


    public func `case`(_ left: SQLExpression, _ operator: SQLBinaryOperator, _ right: SQLExpression) -> Self {
        return self.case(SQLBinaryExpression(left: left, op: `operator`, right: right))
    }

    public func `case`<E>(_ left: SQLIdentifier, _ operator: SQLBinaryOperator, _ right: E) -> Self where E: Encodable {
        return self.case(left, `operator`, SQLBind(right))
    }
}


extension SQLCaseBuilder {
    public func when(_ condition: SQLExpression, then result: SQLExpression) -> Self {
        self.query.cases.append((condition, result))
        return self
    }


    public func when(_ left: SQLExpression, _ op: SQLBinaryOperator, _ right: SQLExpression, then result: SQLExpression) -> Self {
        return self.when(SQLBinaryExpression(left: left, op: op, right: right), then: result)
    }

    public func when<E, R>(
        _ left: SQLIdentifier, _ op: SQLBinaryOperator, _ right: E,
        then result: R
    ) -> Self where E: Encodable, R: Encodable {
        return self.when(SQLBinaryExpression(left: left, op: op, right: SQLBind(right)), then: SQLBind(result))
    }


    public func when<E, R>(_ value: E, then result: R) -> Self where E: Encodable, R: Encodable {
        return self.when(SQLBind(value), then: SQLBind(result))
    }
}


extension SQLCaseBuilder {
    public func `else`(_ result: SQLExpression) -> Self {
        self.query.alternative = result
        return self
    }

    public func `else`(_ identifier: SQLIdentifier) -> Self {
        return self.else(identifier as SQLExpression)
    }

    public func `else`<E>(_ value: E) -> Self where E: Encodable {
        return self.else(SQLBind(value))
    }
}


extension SQLSelectBuilder {
    public func column(`case`: (SQLCaseBuilder) -> SQLCaseBuilder) -> Self {
        return self.column(`case`(.init()).query)
    }
}

extension SQLPredicateBuilder {
    public func `where`(`case`: (SQLCaseBuilder) -> SQLCaseBuilder) -> Self {
        return self.where(`case`(.init()).query)
    }
}
