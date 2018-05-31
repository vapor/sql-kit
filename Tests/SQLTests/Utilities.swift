import SQL
import XCTest

final class TestDatabase: SQLSupporting {
    typealias ColumnType = String
}

/// A non-specific SQL serializer.
final class TestSQLSerializer: SQLSerializer {
    typealias Database = TestDatabase

    init() { }
    
    public func serialize(columnType: String) -> String {
        return columnType
    }
}


@discardableResult
func assert(query: Query<TestDatabase>, equal sql: String, file: StaticString = #file, line: UInt = #line) -> Binds {
    var binds: Binds = .init()
    XCTAssertEqual(TestSQLSerializer().serialize(query: query, binds: &binds), sql, file: file, line: line)
    return binds
}
