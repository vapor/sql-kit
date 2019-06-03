import SQLKit

final class TestDatabase: SQLDatabase {
    let eventLoop: EventLoop
    var results: [String]
    
    init() {
        self.eventLoop = EmbeddedEventLoop()
        self.results = []
    }
    
    func execute(sql query: SQLExpression, _ onRow: @escaping (SQLRow) throws -> ()) -> EventLoopFuture<Void> {
        var serializer = SQLSerializer(dialect: GenericDialect())
        query.serialize(to: &serializer)
        results.append(serializer.sql)
        return self.eventLoop.makeSucceededFuture(())
    }
}

struct GenericDialect: SQLDialect {
    init() { }
    var identifierQuote: SQLExpression {
        return SQLRaw("`")
    }
    
    var literalStringQuote: SQLExpression {
        return SQLRaw("'")
    }
    
    func nextBindPlaceholder() -> SQLExpression {
        return SQLRaw("?")
    }
    
    func literalBoolean(_ value: Bool) -> SQLExpression {
        switch value {
        case true: return SQLRaw("true")
        case false: return SQLRaw("false")
        }
    }
    
    var autoIncrementClause: SQLExpression {
        return SQLRaw("AUTOINCREMENT")
    }
}
