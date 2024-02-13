public struct SQLSerializer: Sendable {
    public var sql: String
    public var binds: [any Encodable & Sendable]
    public let database: any SQLDatabase
    
    @inlinable
    public var dialect: any SQLDialect {
        self.database.dialect
    }
    
    @inlinable
    public init(database: any SQLDatabase) {
        self.sql = ""
        self.binds = []
        self.database = database
    }
    
    @inlinable
    public mutating func write(bind encodable: some Encodable & Sendable) {
        self.binds.append(encodable)
        self.dialect.bindPlaceholder(at: self.binds.count)
            .serialize(to: &self)
    }
    
    @inlinable
    public mutating func write(_ sql: String) {
        self.sql += sql
    }
}
