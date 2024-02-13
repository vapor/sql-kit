public struct SQLRaw: SQLExpression {
    public var sql: String

    @available(*, deprecated, message: "Binds set in an `SQLRaw` are ignored. Use `SQLBind`instead.")
    public var binds: [any Encodable & Sendable] = []
    
    @inlinable
    public init(_ sql: String) {
        self.sql = sql
    }

    @available(*, deprecated, message: "Binds set in an `SQLRaw` are ignored. Use `SQLBind`instead.")
    @inlinable
    public init(_ sql: String, _ binds: [any Encodable & Sendable]) {
        self.sql = sql
        self.binds = binds
    }
    
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write(self.sql)
    }
}
