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
