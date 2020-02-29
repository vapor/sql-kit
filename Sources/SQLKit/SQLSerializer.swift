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

extension SQLSerializer {
    public mutating func statement(_ closure: (inout SQLStatement) -> ()) {
        var sql = SQLStatement(parts: [], database: self.database)
        closure(&sql)
        sql.serialize(to: &self)
    }
}

public struct SQLStatement: SQLExpression {
    public var parts: [SQLExpression]
    let database: SQLDatabase

    public var dialect: SQLDialect {
        self.database.dialect
    }

    public mutating func append(_ raw: String) {
        self.append(SQLRaw(raw))
    }

    public mutating func append(_ part: SQLExpression) {
        self.parts.append(part)
    }

    public func serialize(to serializer: inout SQLSerializer) {
        for (i, part) in parts.enumerated() {
            if i != 0 {
                serializer.write(" ")
            }
            part.serialize(to: &serializer)
        }
    }
}
