public struct SQLRaw: SQLExpression {
    public var sql: String
    public var binds: [Encodable]
    
    @inlinable
    public init(_ sql: String, _ binds: [Encodable] = []) {
        self.sql = sql
        self.binds = binds
    }
    
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write(self.sql)
        serializer.binds += self.binds
    }
}
