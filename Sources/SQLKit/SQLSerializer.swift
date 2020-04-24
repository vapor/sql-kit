public struct SQLSerializer {
    public var sql: String
    public var binds: [Encodable]
    public let database: SQLDatabase
    public var dialect: SQLDialect {
        self.database.dialect
    }
    
    public init(database: SQLDatabase) {
        self.sql = ""
        self.binds = []
        self.database = database
    }
    
    public mutating func write(bind encodable: Encodable) {
        self.binds.append(encodable)
        self.dialect.bindPlaceholder(at: self.binds.count)
            .serialize(to: &self)
    }
    
    public mutating func write(_ sql: String) {
        self.sql += sql
    }
}
