/// A parameterizied value bound to the SQL query.
public struct SQLBind: SQLExpression {
    public let encodable: Encodable
    
    public init(_ encodable: Encodable) {
        self.encodable = encodable
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write(bind: self.encodable)
    }
}

extension SQLBind {
    public static func group(_ items: [Encodable]) -> SQLExpression {
        SQLGroupExpression(items.map(SQLBind.init))
    }
}
