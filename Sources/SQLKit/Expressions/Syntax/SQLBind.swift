/// A parameterizied value bound to the SQL query.
public struct SQLBind: SQLExpression {
    public let encodable: any Encodable
    
    @inlinable
    public init(_ encodable: any Encodable) {
        self.encodable = encodable
    }
    
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write(bind: self.encodable)
    }
}

extension SQLBind {
    @inlinable
    public static func group(_ items: [any Encodable]) -> any SQLExpression {
        SQLGroupExpression(items.map(SQLBind.init))
    }
}
