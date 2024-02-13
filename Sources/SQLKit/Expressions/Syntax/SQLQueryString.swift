public struct SQLQueryString {
    @usableFromInline
    var fragments: [any SQLExpression]
    
    /// Create a query string from a plain string containing raw SQL.
    @inlinable
    public init(_ string: some StringProtocol) {
        self.fragments = [SQLRaw(.init(string))]
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
    // See `StringInterpolationProtocol.init(literalCapacity:interpolationCount:)`
    @inlinable
    public init(literalCapacity: Int, interpolationCount: Int) {
        self.fragments = []
        self.fragments.reserveCapacity(literalCapacity + interpolationCount)
    }
    
    /// Adds raw SQL to the string. Despite the use of the term "literal" dictated by the
    /// interpolation protocol, this produces ``SQLRaw`` content, _not_ SQL string literals.
    @inlinable
    public mutating func appendLiteral(_ literal: some StringProtocol) {
        self.fragments.append(SQLRaw(.init(literal)))
    }
    
    /// A legacy alias of ``appendLiteral(_:)``.
    public mutating func appendInterpolation(_ literal: some StringProtocol) {
        self.appendInterpolation(unsafeRaw: literal)
    }

    /// Adds an interpolated string of raw SQL, potentially including associated parameter bindings.
    ///
    /// > Warning: This interpolation is inherently unsafe. It provides no protection whatsoever against SQL
    ///   injection attacks and has no awareness of dialects or syntactical constraints. Use a more specific
    ///   type of expression if at all possible.
    @inlinable
    public mutating func appendInterpolation(unsafeRaw value: some StringProtocol) {
        self.fragments.append(SQLRaw(.init(value)))
    }

    /// [DEPRECATED] Adds an interpolated string of raw SQL.
    ///
    /// > Important: This is a deprecated legacy alias of ``appendInterpolation(unsafeRaw:)``. Update your
    ///   code to use that method, or better yet to not use raw interpolation at all.
    @available(*, deprecated, renamed: "appendInterpolation(unsafeRaw:)")
    public mutating func appendInterpolation(raw value: String) {
        self.appendInterpolation(unsafeRaw: value)
    }
    
    /// Embed an `Encodable` value as a binding in the SQL query.
    @inlinable
    public mutating func appendInterpolation(bind value: some Encodable & Sendable) {
        self.fragments.append(SQLBind(value))
    }

    /// Embed multiple `Encodable` values as bindings in the SQL query, separating the bind
    /// placeholders with commas. Useful in conjunction with the `IN` operator.
    @inlinable
    public mutating func appendInterpolation(binds values: [any Encodable & Sendable]) {
        self.fragments.append(SQLList(values.map { SQLBind($0) }))
    }
    
    /// Embed an integer as a literal value, as if via ``SQLLiteral/numeric(_:)``
    /// Use this preferentially to ensure values are appropriately represented in the database's dialect.
    @inlinable
    public mutating func appendInterpolation(literal: some BinaryInteger) {
        self.fragments.append(SQLLiteral.numeric("\(literal)"))
    }

    /// Embed a `Bool` as a literal value, as if via ``SQLLiteral/boolean(_:)``.
    @inlinable
    public mutating func appendInterpolation(_ value: Bool) {
        self.fragments.append(SQLLiteral.boolean(value))
    }

    /// Embed a `String` as a literal value, as if via ``SQLLiteral/string(_:)``.
    ///
    /// Use this preferentially to ensure string values are appropriately represented in the
    /// database's dialect.
    @inlinable
    public mutating func appendInterpolation(literal: some StringProtocol) {
        self.fragments.append(SQLLiteral.string(.init(literal)))
    }

    /// Embed an array of `String`s as a list of literal values, using the `joiner` to separate them.
    ///
    /// Example:
    ///
    ///     "SELECT \(literals: "a", "b", "c", "d", joinedBy: "||") FROM nowhere"
    ///
    /// Rendered by the SQLite dialect:
    ///
    ///     SELECT 'a'||'b'||'c'||'d' FROM nowhere
    @inlinable
    public mutating func appendInterpolation(literals: [some StringProtocol], joinedBy joiner: some StringProtocol) {
        self.fragments.append(SQLList(literals.map { SQLLiteral.string(.init($0)) }, separator: SQLRaw(.init(joiner))))
    }

    /// Embed a `String` as an SQL identifier, as if with ``SQLIdentifier``
    /// Use this preferentially to ensure table names, column names, and other non-keyword identifiers
    /// are appropriately represented in the database's dialect.
    @inlinable
    public mutating func appendInterpolation(ident: some StringProtocol) {
        self.fragments.append(SQLIdentifier(.init(ident)))
    }

    /// Embed an array of `String`s as a list of SQL identifiers, using the `joiner` to separate them.
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
    public mutating func appendInterpolation(idents: [some StringProtocol], joinedBy joiner: some StringProtocol) {
        self.fragments.append(SQLList(idents.map { SQLIdentifier(.init($0)) }, separator: SQLRaw(.init(joiner))))
    }

    /// Embed any ``SQLExpression`` into the string, to be serialized according to its type.
    @inlinable
    public mutating func appendInterpolation(_ expression: any SQLExpression) {
        self.fragments.append(expression)
    }
}

extension SQLQueryString {
    @inlinable
    public static func +(lhs: SQLQueryString, rhs: SQLQueryString) -> SQLQueryString {
        "\(lhs)\(rhs)"
    }
    
    @inlinable
    public static func +=(lhs: inout SQLQueryString, rhs: SQLQueryString) {
        lhs.fragments.append(contentsOf: rhs.fragments)
    }
}

extension Array<SQLQueryString> {
    @inlinable
    public func joined(separator: some StringProtocol) -> SQLQueryString {
        let separator = "\(unsafeRaw: separator)" as SQLQueryString
        return self.first.map { self.dropFirst().lazy.reduce($0) { $0 + separator + $1 } } ?? ""
    }
}

extension SQLQueryString: SQLExpression {
    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        self.fragments.forEach { $0.serialize(to: &serializer) }
    }
}
