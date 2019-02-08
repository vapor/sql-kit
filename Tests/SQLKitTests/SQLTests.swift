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
    func sqlQuery(_ query: SQLExpression, _ onRow: @escaping (SQLRow) throws -> ()) -> EventLoopFuture<Void> {
        var serializer = SQLSerializer(dialect: GenericDialect())
        query.serialize(to: &serializer)
        print("[SQL] \(serializer.sql)")
        return self.eventLoop.makeSucceededFuture(())
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
    
    func nextBindPlaceholder() -> SQLExpression {
        return "$"
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
