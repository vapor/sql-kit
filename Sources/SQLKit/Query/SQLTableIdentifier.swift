public struct SQLTableIdentifier: SQLExpression {
    public var name: SQLExpression

    public init(_ name: String) {
        self.init(SQLIdentifier(name))
    }

    public init(_ name: SQLExpression) {
        self.name = name
    }

    public func serialize(to serializer: inout SQLSerializer) {
        self.name.serialize(to: &serializer)
    }
}
