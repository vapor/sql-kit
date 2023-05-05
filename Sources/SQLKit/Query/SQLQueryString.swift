public struct SQLQueryString {
    @usableFromInline
    var fragments: [any SQLExpression]
    
    /// Create a query string from a plain string containing raw SQL.
    @inlinable
    public init<S: StringProtocol>(_ string: S) {
        self.fragments = [SQLRaw(string.description)]
    }
}

extension SQLQueryString: ExpressibleByStringLiteral {
    /// See `ExpressibleByStringLiteral.init(stringLiteral:)`
    @inlinable
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension SQLQueryString: ExpressibleByStringInterpolation {
    /// See `ExpressibleByStringInterpolation.init(stringInterpolation:)`
    @inlinable
    public init(stringInterpolation: SQLQueryString) {
        self.fragments = stringInterpolation.fragments
    }
}

extension SQLQueryString: StringInterpolationProtocol {
    /// See `StringInterpolationProtocol.init(literalCapacity:interpolationCount:)`
    @inlinable
    public init(literalCapacity: Int, interpolationCount: Int) {
        self.fragments = []
    }
    
    /// Adds raw SQL to the string. Despite the use of the term "literal" dictated by the interpolation protocol, this
    /// produces `SQLRaw` content, _not_ SQL string literals.
    @inlinable
    public mutating func appendLiteral(_ literal: String) {
        self.fragments.append(SQLRaw(literal))
    }    
    
    /// Adds an interpolated string of raw SQL. Despite the use of the term "literal" dictated by the interpolation
    /// protocol, this produces `SQLRaw` content, _not_ SQL string literals.
    @available(*, deprecated, message: "Use 'raw' label")
    @inlinable
    public mutating func appendInterpolation(_ literal: String) {
        self.fragments.append(SQLRaw(literal))
    }
    
    /// Adds an interpolated string of raw SQL. Despite the use of the term "literal" dictated by the interpolation
    /// protocol, this produces `SQLRaw` content, _not_ SQL string literals.
    @inlinable
    public mutating func appendInterpolation(raw value: String) {
        self.fragments.append(SQLRaw(value.description))
    }
    
    /// Embed an ``Encodable`` value as a binding in the SQL query.
    @inlinable
    public mutating func appendInterpolation(bind value: any Encodable) {
        self.fragments.append(SQLBind(value))
    }

    /// Embed multiple ``Encodable`` values as bindings in the SQL query, separating the bind placeholders with commas.
    /// Most commonly useful when working with the `IN` operator.
    @inlinable
    public mutating func appendInterpolation(binds values: [any Encodable]) {
        self.fragments.append(SQLList(values.map(SQLBind.init)))
    }
    
    /// Embed an integer as a literal value, as if via `SQLLiteral.numeric()`
    /// Use this preferentially to ensure values are appropriately represented in the database's dialect.
    @inlinable
    public mutating func appendInterpolation<I: BinaryInteger>(literal: I) {
        self.fragments.append(SQLLiteral.numeric("\(literal)"))
    }

    /// Embed a `Bool` as a literal value, as if via `SQLLiteral.boolean()`
    @inlinable
    public mutating func appendInterpolation(_ value: Bool) {
        self.fragments.append(SQLLiteral.boolean(value))
    }

    /// Embed a `String` as a literal value, as if via `SQLLiteral.string()`
    /// Use this preferentially to ensure string values are appropriately represented in the database's dialect.
    @inlinable
    public mutating func appendInterpolation(literal: String) {
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
    @inlinable
    public mutating func appendInterpolation(literals: [String], joinedBy joiner: String) {
        self.fragments.append(SQLList(literals.map(SQLLiteral.string(_:)), separator: SQLRaw(joiner)))
    }

    /// Embed a `String` as an SQL identifier, as if with `SQLIdentifier`
    /// Use this preferentially to ensure table names, column names, and other non-keyword identifiers are appropriately
    /// represented in the database's dialect.
    @inlinable
    public mutating func appendInterpolation(ident: String) {
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
    @inlinable
    public mutating func appendInterpolation(idents: [String], joinedBy joiner: String) {
        self.fragments.append(SQLList(idents.map(SQLIdentifier.init(_:)), separator: SQLRaw(joiner)))
    }

    /// Embed any `SQLExpression` into the string, to be serialized according to its type.
    @inlinable
    public mutating func appendInterpolation(_ expression: any SQLExpression) {
        self.fragments.append(expression)
    }
}

extension SQLQueryString {
    @inlinable
    public static func +(lhs: SQLQueryString, rhs: SQLQueryString) -> SQLQueryString {
        return "\(lhs)\(rhs)"
    }
    
    @inlinable
    public static func +=(lhs: inout SQLQueryString, rhs: SQLQueryString) {
        lhs.fragments.append(contentsOf: rhs.fragments)
    }
}

extension Array where Element == SQLQueryString {
    @inlinable
    public func joined(separator: String) -> SQLQueryString {
        let separator = "\(raw: separator)" as SQLQueryString
        return self.first.map { self.dropFirst().lazy.reduce($0) { $0 + separator + $1 } } ?? ""
    }
}

extension SQLQueryString: SQLExpression {
    /// See ``SQLExpression/serialize(to:)``.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        self.fragments.forEach { $0.serialize(to: &serializer) }
    }
}
