/// A parameterizied value bound to the SQL query.
public struct SQLBind: SQLExpression {
    /// The actual bound value.
    public let encodable: any Encodable & Sendable
    
    /// Create a binding to a value.
    @inlinable
    public init(_ encodable: some Encodable & Sendable) {
        self.encodable = encodable
    }
    
    /// Create a lsit of bindings to an array of values, with the placeholders wrapped in an ``SQLGroupExpression``.
    @inlinable
    public static func group(_ items: some Collection<some Encodable & Sendable>) -> any SQLExpression {
        SQLGroupExpression(items.map(SQLBind.init))
    }

    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write(bind: self.encodable)
    }
}
