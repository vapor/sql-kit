import SQLKit
import SQLKitBenchmark
import XCTest

final class SQLKitTests: XCTestCase {
    func testSelect() throws {
        let db = PrintDatabase()
        let benchmarker = SQLBenchmarker(on: db)
        try benchmarker.run()
    }

    static let allTests = [
        ("testSelect", testSelect),
    ]
}


struct PrintDatabase: SQLDatabase {
    let eventLoop: EventLoop
    init() {
        self.eventLoop = EmbeddedEventLoop()
    }
    func execute(_ query: SQLExpression, _ onRow: @escaping (SQLRow) throws -> ()) -> EventLoopFuture<Void> {
        var serializer: SQLSerializer = BufferSerializer()
        query.serialize(to: &serializer)
        let buffer = serializer as! BufferSerializer
        print("[SQL] \(buffer.sql)")
        return self.eventLoop.newSucceededFuture(result: ())
    }
}

struct BufferSerializer: SQLSerializer {
    var dialect: SQLDialect
    
    var sql: String
    var binds: [Encodable]
    
    init() {
        self.dialect = GenericDialect()
        self.sql = ""
        self.binds = []
    }
    
    mutating func bind(_ encodable: Encodable) {
        self.binds.append(encodable)
    }
    
    mutating func write(_ sql: String) {
        self.sql += sql
    }
}

extension String: SQLExpression {
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write(self)
    }
}

struct GenericDialect: SQLDialect {
    init() { }
    var identifierQuote: SQLExpression {
        return "\""
    }
    
    var literalStringQuote: SQLExpression {
        return "'"
    }
    
    var bindPlaceholder: SQLExpression {
        return "?"
    }
    
    func literalBoolean(_ value: Bool) -> SQLExpression {
        switch value {
        case true: return "true"
        case false: return "false"
        }
    }
    
    var autoIncrementClause: SQLExpression {
        return "AUTOINCREMENT"
    }
}
