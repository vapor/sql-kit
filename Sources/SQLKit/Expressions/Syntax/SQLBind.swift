/// A parameterizied value bound to the SQL query.
public struct SQLBind: SQLExpression {
    public let encodable: any Encodable & Sendable
    
    @inlinable
    public init(_ encodable: some Encodable & Sendable) {
        self.encodable = encodable
    }
    
    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write(bind: self.encodable)
    }
}

extension SQLBind {
    @inlinable
    public static func group(_ items: some Collection<some Encodable & Sendable>) -> any SQLExpression {
        SQLGroupExpression(items.map(SQLBind.init))
    }
}
