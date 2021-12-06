public struct SQLAlias: SQLExpression {
    public var expression: SQLExpression
    public var alias: SQLExpression
    
    public init(_ expression: SQLExpression, as alias: SQLExpression) {
        self.expression = expression
        self.alias = alias
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        self.expression.serialize(to: &serializer)
        serializer.write(" AS ")
        self.alias.serialize(to: &serializer)
    }
}

extension SQLAlias {
    public init(_ expression: SQLExpression, as alias: String) {
        self.init(expression, as: SQLIdentifier(alias))
    }
}
