/// An expression consisting of an array of constituent subexpressions generated by custom string interpolations.
///
/// Query strings are primarily intended for use with ``SQLRawBuilder``, providing for the inclusion of bound
/// parameters in otherwise "raw" queries. The API also supports some of the more commonly used quoting functionality.
/// Query strings are also ``SQLExpression``s, allowing them to be used almost anywhere in SQLKit.
///
/// A corollary to this is that, while a given ``SQLQueryString`` can represent an entire complete "query" to execute
/// against a database, it can also - as with any ``SQLExpression`` but particularly similarly to ``SQLStatement`` -
/// represent any lesser fragment of SQL right down to an empty string, or anywhere in between.
///
/// Example usage:
///
/// ```swift
/// // As an entire query:
/// try await database.raw("""
///     UPDATE \(ident: "foo")
///         SET \(ident: "bar")=\(bind: value)
///         WHERE \(ident: "baz")=\(literal: "bop")
///     """).run()
///
/// // As an SQL fragment (albeit in an extremely contrived fashion):
/// try await database.update("foo")
///     .set("bar", to: value)
///     .where("\(ident: "baz")" as SQLQueryString, .equal, "\(literal: "bop")" as SQLQueryString)
///     .run()
/// ```
///
/// ``SQLQueryString``'s additional interpolations (such as `\(ident:)`, `\(literal:)`, etc., as well as the ability
/// to embed arbitrary expressions with `\(_:)`) are useful in particular for writing raw queries which are
/// nonetheless compatible with multiple SQL dialects, such as in the following example:
///
/// ```swift
/// let messyIdentifer = someCondition ? "abcd{}efgh" : "marmalade!!" // invalid identifiers if not escaped
/// try await database.raw("""
///     SELECT \(ident: messyIdentifier) FROM \(ident: "whatever") WHERE \(ident: "x")=\(bind: "foo")
///     """).all()
/// // This query renders differently in various dialect:
/// // - PostgreSQL: SELECT "abcd{}efgh" FROM "whatever" WHERE "x"=$0 ["foo"]
/// // -      MySQL: SELECT `abcd{}efgh` FROM `whatever` WHERE `x`=?  ["foo"]
/// // -     SQLite: SELECT "abcd{}efgh" FROM "whatever" WHERE "x"=?0 ["foo"]
/// ```
///
/// > Bonus remarks:
/// >
/// > - Even in Swift 5.10, language limitations prevent supporting literal strings everywhere ``SQLExpression``s
/// >   are allowed, because the necessary conformance (e.g.
/// >   `extension SQLExpression: ExtensibleByStringLiteral where Self == SQLQueryString`) is not allowed by the
/// >   compiler. The maintainer of this package at the time of this writing considers this to perhaps be a blessing
/// >   in disguise, given the concern that it is already "too easy" as things stand to embed raw SQL into queries
/// >   without worrying about injection concerns. As she might put it, "You can already write entire raw queries
/// >   without escaping any of the things you ought to be," paying no heed to the fact that she was the one who
/// >   brought up the topic in the first place.
/// > - ``SQLQueryString`` is almost identical to ``SQLStatement``; they track content identically, operate by
/// >   building up output based on progressive inputs, and often (indeed, usually) represent entire queries. At this
/// >   point, the only remaining reason they haven't been made into a single type is the confusion wouldn't be worth
/// >   it in light of the expectation, at the time of this writing, that this package will soon be receiving a major
/// >   version bump, at which point far more opportunities will indeed abound.
public struct SQLQueryString: SQLExpression, ExpressibleByStringInterpolation, StringInterpolationProtocol {
    @usableFromInline
    var fragments: [any SQLExpression]
    
    /// Create a query string from a plain string containing raw SQL.
    @inlinable
    public init(_ string: String) {
        self.fragments = [SQLRaw(string)]
    }

    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        self.fragments.forEach { $0.serialize(to: &serializer) }
    }
}

// MARK: - Interpolation support
extension SQLQueryString {
    // See `ExpressibleByStringLiteral.init(stringLiteral:)`.
    @inlinable
    public init(stringLiteral value: String) {
        self.init(value)
    }

    // See `ExpressibleByStringInterpolation.init(stringInterpolation:)`.
    @inlinable
    public init(stringInterpolation: SQLQueryString) {
        /// Since ``SQLQueryString`` is its own string interpolation type, we can just use it as-is and save
        /// any additional allocations or copying.
        self = stringInterpolation
    }

    // See `StringInterpolationProtocol.init(literalCapacity:interpolationCount:)`.
    @inlinable
    public init(literalCapacity: Int, interpolationCount: Int) {
        self.fragments = []
        self.fragments.reserveCapacity(literalCapacity + interpolationCount)
    }
    
    // See `StringInterpolationProtocol.appendLiteral(_:)`.
    @inlinable
    public mutating func appendLiteral(_ literal: String) {
        self.fragments.append(SQLRaw(literal))
    }
}

// MARK: - Custom interpolations
extension SQLQueryString {
    /// Adds an interpolated string of raw SQL, potentially including associated parameter bindings.
    ///
    /// > Warning: This interpolation is inherently unsafe. It provides no protection whatsoever against SQL
    /// > injection attacks and maintains no awareness of dialect considerations or syntactical constraints. Use
    /// > a purpose-specific expression instead whenever possible.
    @inlinable
    public mutating func appendInterpolation(unsafeRaw value: String) {
        self.fragments.append(SQLRaw(value))
    }

    /// Embed an `Encodable` value as a binding in the SQL query.
    ///
    /// This overload is provided as shorthand - `\(bind: "a")` is identical to `\(SQLBind("a"))`.
    @inlinable
    public mutating func appendInterpolation(bind value: any Encodable & Sendable) {
        self.fragments.append(SQLBind(value))
    }

    /// Embed any number of `Encodable` values as bindings in the SQL query, separating the bind
    /// placeholders with commas.
    ///
    /// This overload is equivalent to `\(SQLList(values.map(SQLBind.init(_:))))`.
    @inlinable
    public mutating func appendInterpolation(binds values: [any Encodable & Sendable]) {
        self.fragments.append(SQLList(values.map { SQLBind($0) }))
    }
    
    /// Embed a `Bool` as a literal value, as if via ``SQLLiteral/boolean(_:)``.
    @inlinable
    public mutating func appendInterpolation(_ value: Bool) {
        self.fragments.append(SQLLiteral.boolean(value))
    }

    /// Embed an integer as a literal value, as if via ``SQLLiteral/numeric(_:)``
    ///
    /// Use this interpolation when a value is already known to be safe otherwise, to ensure numeric values are
    /// appropriately and accurately serialized. Do _not_ use this method for arbitrary numeric input; bind such
    /// values to the query via ``SQLBind`` or ``appendInterpolation(bind:)``.
    @inlinable
    public mutating func appendInterpolation(literal: some BinaryInteger) {
        self.fragments.append(SQLLiteral.numeric("\(literal)"))
    }

    /// Embed a floating-point number as a literal value, as if via ``SQLLiteral/numeric(_:)``
    ///
    /// Use this preferentially to ensure values are appropriately represented in the database's dialect.
    @inlinable
    public mutating func appendInterpolation(literal: some BinaryFloatingPoint) {
        self.fragments.append(SQLLiteral.numeric("\(literal)"))
    }

    /// Embed a `String` as a literal value, as if via ``SQLLiteral/string(_:)``.
    ///
    /// Use this preferentially to ensure string values are appropriately represented in the
    /// database's dialect.
    @inlinable
    public mutating func appendInterpolation(literal: String) {
        self.fragments.append(SQLLiteral.string(literal))
    }

    /// Embed an array of `String`s as a list of literal values, placing the `joiner` between each pair of values.
    ///
    /// This is equivalent to adding an ``SQLList`` whose subexpressions are all ``SQLLiteral/string(_:)``s and whose
    /// separator is the `joiner` wrapped by ``SQLRaw``.
    ///
    /// Example:
    ///
    /// ```swift
    /// sqliteDatabase.serialize("""
    ///     SELECT \(literals: "a", "b", "c", "d", joinedBy: "||") FROM \(ident: "nowhere")
    ///     """ as SQLQueryString
    /// ).sql
    /// // SELECT 'a'||'b'||'c'||'d' FROM "nowhere"
    /// ```
    @inlinable
    public mutating func appendInterpolation(literals: [String], joinedBy joiner: String) {
        self.fragments.append(SQLList(literals.map { SQLLiteral.string($0) }, separator: SQLRaw(joiner)))
    }

    /// Embed a `String` as an identifier, as if via ``SQLIdentifier``.
    ///
    /// Use this interpolation preferentially to ensure that table names, column names, and other non-keyword
    /// identifier are correctly quoted and escaped.
    @inlinable
    public mutating func appendInterpolation(ident: String) {
        self.fragments.append(SQLIdentifier(ident))
    }

    /// Embed an array of `String`s as a list of SQL identifiers, using the `joiner` to separate them.
    ///
    /// > Important: This interprets each string as an identifier, _not_ as a literal value!
    ///
    /// Example:
    ///
    /// ```swift
    /// sqliteDatabase.serialize("""
    ///     SELECT
    ///         \(idents: "a", "b", "c", "d", joinedBy: ",")
    ///     FROM
    ///         \(ident: "nowhere")
    ///     """ as SQLQueryString
    /// ).sql
    /// // SELECT "a", "b", "c", "d" FROM "nowhere"
    /// ```
    @inlinable
    public mutating func appendInterpolation(idents: [String], joinedBy joiner: String) {
        self.fragments.append(SQLList(idents.map { SQLIdentifier($0) }, separator: SQLRaw(joiner)))
    }

    /// Embed an arbitary ``SQLExpression`` in the string.
    @inlinable
    public mutating func appendInterpolation(_ expression: any SQLExpression) {
        self.fragments.append(expression)
    }
}

// MARK: - Operators
extension SQLQueryString {
    /// Concatenate two ``SQLQueryString``s and return the combined result.
    @inlinable
    public static func + (lhs: Self, rhs: Self) -> Self {
        "\(lhs)\(rhs)"
    }
    
    /// Append one ``SQLQueryString`` to another in-place.
    @inlinable
    public static func += (lhs: inout Self, rhs: Self) {
        lhs.fragments.append(contentsOf: rhs.fragments)
    }
}

// MARK: - Sequence
extension Sequence<SQLQueryString> {
    /// Returns a new ``SQLQueryString`` formed by concatenating the elements of the sequence, adding the given
    /// separator between each element.
    ///
    /// - Parameter separator: A string to insert between each of the elements in this sequence. The default
    ///   separator is an empty string.
    /// - Returns: A single, concatenated string.
    @inlinable
    public func joined(separator: String = "") -> SQLQueryString {
        self.joined(separator: SQLRaw(separator))
    }

    /// Returns a new ``SQLQueryString`` formed by concatenating the elements of the sequence, adding the given
    /// separator between each element.
    ///
    /// - Parameter separator: An expression to insert between each of the elements in this sequence.
    /// - Returns: A single, concatenated string.
    @inlinable
    public func joined(separator: some SQLExpression) -> SQLQueryString {
        var iter = self.makeIterator()
        var result = iter.next() ?? ""
        
        while let str = iter.next() {
            result.fragments.append(separator)
            result.fragments.append(contentsOf: str.fragments)
        }
        return result
    }
}
