public struct SQLQueryString {
    var fragments: [SQLExpression]
    
    public init<S: StringProtocol>(_ string: S) {
        self.fragments = [SQLRaw(string.description)]
    }
}

extension SQLQueryString: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension SQLQueryString: ExpressibleByStringInterpolation {
    
    public init(stringInterpolation: SQLQueryString) {
        self.fragments = stringInterpolation.fragments
    }
}

extension SQLQueryString: StringInterpolationProtocol {
    public init(literalCapacity: Int, interpolationCount: Int) {
        self.fragments = []
    }
    
    mutating public func appendLiteral(_ literal: String) {
        self.fragments.append(SQLRaw(literal))
    }
    
    mutating public func appendInterpolation(_ literal: String) {
        self.fragments.append(SQLRaw(literal))
    }

    mutating public func appendInterpolation(bind value: Encodable) {
        self.fragments.append(SQLBind(value))
    }

    /// Binds multiple values in a comma separated list.
    /// Commonly used with the `IN` operator.
    mutating public func appendInterpolation(binds values: [Encodable]) {
        self.fragments.append(SQLList(values.map(SQLBind.init)))
    }
}

extension SQLQueryString: SQLExpression {
    public func serialize(to serializer: inout SQLSerializer) {
        self.fragments.forEach { $0.serialize(to: &serializer) }
    }
}
