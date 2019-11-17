import SQLKit
import NIO

final class TestDatabase: SQLDatabase {
    let logger: Logger
    let eventLoop: EventLoop
    var results: [String]
    var dialect: SQLDialect {
        self._dialect
    }
    var _dialect: GenericDialect
    
    init() {
        self.logger = .init(label: "codes.vapor.sql.test")
        self.eventLoop = EmbeddedEventLoop()
        self.results = []
        self._dialect = GenericDialect()
    }
    
    func execute(sql query: SQLExpression, _ onRow: @escaping (SQLRow) -> ()) -> EventLoopFuture<Void> {
        var serializer = SQLSerializer(database: self)
        query.serialize(to: &serializer)
        results.append(serializer.sql)
        return self.eventLoop.makeSucceededFuture(())
    }
}

struct GenericDialect: SQLDialect {
    var name: String {
        "generic sql"
    }
    
    var supportsIfExists: Bool = true

    var identifierQuote: SQLExpression {
        return SQLRaw("`")
    }
    
    var literalStringQuote: SQLExpression {
        return SQLRaw("'")
    }
    
    func bindPlaceholder(at position: Int) -> SQLExpression {
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
