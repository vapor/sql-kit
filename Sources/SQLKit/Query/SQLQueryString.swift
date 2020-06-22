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
    
    /// Embed an integer as a literal value, as if via `SQLLiteral.numeric()`
    /// Use this preferentially to ensure values are appropriately represented in the database's dialect.
    mutating public func appendInterpolation<I: BinaryInteger>(literal: I) {
        self.fragments.append(SQLLiteral.numeric("\(literal)"))
    }

    /// Embed a `Bool` as a literal value, as if via `SQLLiteral.boolean()`
    mutating public func appendInterpolation(_ value: Bool) {
        self.fragments.append(SQLLiteral.boolean(value))
    }

    /// Embed a `String` as a literal value, as if via `SQLLiteral.string()`
    /// Use this preferentially to ensure string values are appropriately represented in the database's dialect.
    mutating public func appendInterpolation(literal: String) {
        self.fragments.append(SQLLiteral.string(literal))
    }

    /// Embed an array of `Strings` as a list of literal values, using the `joiner` to separate them.
    ///
    /// Example:
    ///
    ///     "SELECT \(literals: "a", "b", "c", "d", joinedBy: "||") FROM nowhere"
    ///
    /// Rendered by the SQLite dialect:
    ///
    ///     SELECT 'a'||'b'||'c'||'d' FROM nowhere
    mutating public func appendInterpolation(literals: [String], joinedBy joiner: String) {
        self.fragments.append(SQLList(literals.map(SQLLiteral.string(_:)), separator: SQLRaw(joiner)))
    }

    /// Embed a `String` as an SQL identifier, as if with `SQLIdentifier`
    /// Use this preferentially to ensure table names, column names, and other non-keyword identifiers are appropriately
    /// represented in the database's dialect.
    mutating public func appendInterpolation(ident: String) {
        self.fragments.append(SQLIdentifier(ident))
    }

    /// Embed an array of `Strings` as a list of SQL identifiers, using the `joiner` to separate them.
    ///
    /// - Important: This interprets each string as an identifier, _not_ as a literal value!
    ///
    /// Example:
    ///
    ///     "SELECT \(idents: "a", "b", "c", "d", joinedBy: ",") FROM \(ident: "nowhere")"
    ///
    /// Rendered by the SQLite dialect:
    ///
    ///     SELECT "a", "b", "c", "d" FROM "nowhere"
    mutating public func appendInterpolation(idents: [String], joinedBy joiner: String) {
        self.fragments.append(SQLList(idents.map(SQLIdentifier.init(_:)), separator: SQLRaw(joiner)))
    }

    /// Embed any `SQLExpression` into the string, to be serialized according to its type.
    mutating public func appendInterpolation(_ expression: SQLExpression) {
        self.fragments.append(expression)
    }
}

extension SQLQueryString: SQLExpression {
    /// See `SQLExpression.serialize(to:)`
    public func serialize(to serializer: inout SQLSerializer) {
        self.fragments.forEach { $0.serialize(to: &serializer) }
    }
}
