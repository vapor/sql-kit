/// An escaped identifier, i.e., `"name"`.
public struct SQLIdentifier: SQLExpression, ExpressibleByStringLiteral {
    /// String value.
    public var string: String
    
    /// Create a new ``SQLIdentifier``.
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
        if let rawQuote = (serializer.dialect.identifierQuote as? SQLRaw)?.sql {
            serializer.write("\(rawQuote)\(self.string.sqlkit_replacing(rawQuote, with: "\(rawQuote)\(rawQuote)"))\(rawQuote)")
        } else {
            serializer.dialect.identifierQuote.serialize(to: &serializer)
            serializer.write(self.string)
            serializer.dialect.identifierQuote.serialize(to: &serializer)
        }
    }
}
