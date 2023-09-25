public struct SQLAlias: SQLExpression {
    public var expression: any SQLExpression
    public var alias: any SQLExpression
    
    @inlinable
    public init(_ expression: any SQLExpression, as alias: any SQLExpression) {
        self.expression = expression
        self.alias = alias
    }
    
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        self.expression.serialize(to: &serializer)
        serializer.write(" AS ")
        self.alias.serialize(to: &serializer)
    }
}

extension SQLAlias {
    @inlinable
    public init(_ expression: any SQLExpression, as alias: String) {
        self.init(expression, as: SQLIdentifier(alias))
    }
}
