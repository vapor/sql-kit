public struct SQLCaseExpression: SQLExpression {
    public var expression: SQLExpression?
    public var cases: [(condition: SQLExpression, result: SQLExpression)]
    public var alternative: SQLExpression?

    public init(
        _ expression: SQLExpression? = nil,
        when cases: [(SQLExpression, SQLExpression)],
        `else`: SQLExpression? = nil
    ) {
        self.expression = expression
        self.cases = cases
        self.alternative = `else`
    }

    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write("CASE")

        if let expression = self.expression {
            serializer.write(" ")
            expression.serialize(to: &serializer)
        }

        self.cases.forEach {
            serializer.write(" WHEN ")
            $0.condition.serialize(to: &serializer)
            serializer.write(" THEN ")
            $0.result.serialize(to: &serializer)
        }

        self.alternative.map {
            serializer.write(" ELSE ")
            $0.serialize(to: &serializer)
        }

        serializer.write(" END")
    }
}

extension SQLCaseExpression {
    public init(_ expression: SQLExpression, when cases: (SQLLiteral, SQLLiteral)..., else alternative: SQLLiteral? = nil) {
        self.init(expression, when: cases, else: alternative)
    }

    public init(when cases: (SQLExpression, SQLLiteral)..., else alternative: SQLLiteral? = nil) {
        self.init(nil, when: cases, else: alternative)
    }
}
