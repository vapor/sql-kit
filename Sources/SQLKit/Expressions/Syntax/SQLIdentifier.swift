/// A fundamental syntactical expression - a quoted identifier (also often referred to as a "name" or "object name").
///
/// Most identifiers in SQL are references to various objects - tables, columns, functions, indexes, constraints,
/// etc.; if something is not a keyword, punctuation, or a literal, it is more likely than not an identifier.
///
/// In most SQL dialects, quoting is only required for identifiers if they contain characters not otherwise allowed in
/// identifiers in that dialect or conflict with an SQL keyword, but may optionally be included even when not needed.
/// For the sake of maximum correctness, maximum consistency, and avoiding the need to do expensive checks to check
/// for invalid characters, ``SQLIdentifier`` adds quoting unconditionally.
///
/// To avoid the risk of accidental SQL injection vulnerabilities, in addition to quoting, identifiers are scanned for
/// the identifier quote character(s) themselves; if found, they are escaped appropriately (by doubling any embedded
/// quoting character(s), a syntax supported by all known dialects).
public struct SQLIdentifier: SQLExpression, ExpressibleByStringLiteral {
    /// The actual identifier itself, unescaped and unquoted.
    public var string: String
    
    /// Create an identifier with a string.
    @inlinable
    public init(_ string: String) {
        self.string = string
    }
    
    // See `ExpressibleByStringLiteral.init(stringLiteral:)`.
    @inlinable
    public init(stringLiteral value: String) {
        self.init(value)
    }

    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        /// This is another instance where legacy API choices limit the robustness of the API's overall behavior.
        /// Specifically, ``SQLDialect`` allows the ``SQLDialect/identifierQuote`` and
        /// ``SQLDialect/literalStringQuote-3ur0m`` to be specified as arbitrary ``SQLExpression``s; this probably
        /// seemed like a good idea for flexibility at the time, but in reality creates additional performance
        /// bottlenecks and prevents error-proof quoting, short of making ``SQLDialect`` even more confusing (or a
        /// major version bump).  Fortunately, in practice all knwon dialects always return their quoting characters
        /// as instances of ``SQLRaw``, so we check for that case and perform the appropriate quoting and/or escaping
        /// as needed, while falling back to quoting without escaping if the check fails.
        if let rawQuote = (serializer.dialect.identifierQuote as? SQLRaw)?.sql {
            serializer.write("\(rawQuote)\(self.string.sqlkit_replacing(rawQuote, with: "\(rawQuote)\(rawQuote)"))\(rawQuote)")
        } else {
            serializer.dialect.identifierQuote.serialize(to: &serializer)
            serializer.write(self.string)
            serializer.dialect.identifierQuote.serialize(to: &serializer)
        }
    }
}
