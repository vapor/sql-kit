public protocol SQLDialect {
    var identifierQuote: SQLExpression { get }
    var literalStringQuote: SQLExpression { get }
    var autoIncrementClause: SQLExpression { get }
    func bindPlaceholder(at position: Int) -> SQLExpression
    func literalBoolean(_ value: Bool) -> SQLExpression
    var literalDefault: SQLExpression { get }
    var supportsIfExists: Bool { get }
}

extension SQLDialect {
    public var literalDefault: SQLExpression {
        return SQLRaw("DEFAULT")
    }

    public var supportsIfExists: Bool {
        return true
    }
}
