public struct SQLRaw: SQLExpression {
    public var sql: String
    
    public var binds: [Encodable]
    
    public init(sql: String, binds: [Encodable] = []) {
        self.sql = sql
        self.binds = []
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write(self.sql)
        serializer.binds += self.binds
    }
}
