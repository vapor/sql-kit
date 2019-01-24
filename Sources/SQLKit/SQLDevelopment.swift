public protocol SQLExpression {
    func serialize(to serializer: inout SQLSerializer)
}

extension Array where Element == SQLExpression {
    public func serialize(to serializer: inout SQLSerializer, joinedBy separator: String) {
        var first = true
        for el in self {
            if !first {
                serializer.write(separator)
            }
            first = false
            el.serialize(to: &serializer)
        }
    }
}


public protocol SQLDialect {
    var identifierQuote: SQLExpression { get }
    
    var literalStringQuote: SQLExpression { get }
    
    var bindPlaceholder: SQLExpression { get }
    
    func literalBoolean(_ value: Bool) -> SQLExpression
    
    var autoIncrementClause: SQLExpression { get }
}

public protocol SQLSerializer {
    mutating func bind(_ encodable: Encodable)
    mutating func write(_ sql: String)
    var dialect: SQLDialect { get }
}
