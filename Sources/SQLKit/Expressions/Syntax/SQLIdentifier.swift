/// An escaped identifier, i.e., `"name"`.
public struct SQLIdentifier: SQLExpression {
    /// String value.
    public var string: String
    
    /// Creates a new `SQLIdentifier`.
    @inlinable
    public init(_ string: String) {
        self.string = string
    }
    
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.dialect.identifierQuote.serialize(to: &serializer)
        serializer.write(self.string)
        serializer.dialect.identifierQuote.serialize(to: &serializer)
    }
}

extension SQLIdentifier: ExpressibleByStringLiteral {
    @inlinable
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}
