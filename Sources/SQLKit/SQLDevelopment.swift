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

public struct SQLSerializer {
    public var sql: String
    public var dialect: SQLDialect
    public var binds: [Encodable]
    
    public init(dialect: SQLDialect) {
        self.sql = ""
        self.dialect = dialect
        self.binds = []
    }
    
    public mutating func bind(_ encodable: Encodable) {
        self.binds.append(encodable)
    }
    public mutating func write(_ sql: String) {
        self.sql += sql
    }
}

public protocol SQLDialect {
    var identifierQuote: SQLExpression { get }
    
    var literalStringQuote: SQLExpression { get }
    
    var autoIncrementClause: SQLExpression { get }
    
    mutating func nextBindPlaceholder() -> SQLExpression
    
    func literalBoolean(_ value: Bool) -> SQLExpression
}
