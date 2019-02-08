public protocol SQLDialect {
    var identifierQuote: SQLExpression { get }
    
    var literalStringQuote: SQLExpression { get }
    
    var autoIncrementClause: SQLExpression { get }
    
    mutating func nextBindPlaceholder() -> SQLExpression
    
    func literalBoolean(_ value: Bool) -> SQLExpression
}
