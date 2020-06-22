public struct SQLQueryString {
    var fragments: [SQLExpression]
    
    /// Create a query string from a plain string containing raw SQL.
    public init<S: StringProtocol>(_ string: S) {
        self.fragments = [SQLRaw(string.description)]
    }
}

extension SQLQueryString: ExpressibleByStringLiteral {
    /// See `ExpressibleByStringLiteral.init(stringLiteral:)`
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension SQLQueryString: ExpressibleByStringInterpolation {
    /// See `ExpressibleByStringInterpolation.init(stringInterpolation:)`
    public init(stringInterpolation: SQLQueryString) {
        self.fragments = stringInterpolation.fragments
    }
}

extension SQLQueryString: StringInterpolationProtocol {
    /// See `StringInterpolationProtocol.init(literalCapacity:interpolationCount:)`
    public init(literalCapacity: Int, interpolationCount: Int) {
        self.fragments = []
    }
    
    /// Adds raw SQL to the string. Despite the use of the term "literal" dictated by the interpolation protocol, this
    /// produces `SQLRaw` content, _not_ SQL string literals.
    mutating public func appendLiteral(_ literal: String) {
        self.fragments.append(SQLRaw(literal))
    }
    
    /// Adds an interpolated string of raw SQL. Despite the use of the term "literal" dictated by the interpolation
    /// protocol, this produces `SQLRaw` content, _not_ SQL string literals.
    mutating public func appendInterpolation(_ literal: String) {
        self.fragments.append(SQLRaw(literal))
    }
    
    /// Embed an `Encodable` value as a binding in the SQL query.
    mutating public func appendInterpolation(bind value: Encodable) {
        self.fragments.append(SQLBind(value))
    }

    /// Embed multiple `Encodable` values as bindings in the SQL query, separating the bind placeholders with commas.
    /// Most commonly useful when working with the `IN` operator.
    mutating public func appendInterpolation(binds values: [Encodable]) {
        self.fragments.append(SQLList(values.map(SQLBind.init)))
    }
}

extension SQLQueryString: SQLExpression {
    /// See `SQLExpression.serialize(to:)`
    public func serialize(to serializer: inout SQLSerializer) {
        self.fragments.forEach { $0.serialize(to: &serializer) }
    }
}
