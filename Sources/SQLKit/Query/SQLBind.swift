/// A parameterizied value bound to the SQL query.
public struct SQLBind: SQLExpression {
    public let encodable: Encodable
    
    public init(_ encodable: Encodable) {
        self.encodable = encodable
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.bind(self.encodable)
        serializer.dialect.nextBindPlaceholder().serialize(to: &serializer)
    }
}
