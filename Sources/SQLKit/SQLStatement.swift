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
