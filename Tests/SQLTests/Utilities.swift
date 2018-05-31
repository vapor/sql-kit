import SQL
import XCTest

@discardableResult
func assert(query: Query, equal sql: String, file: StaticString = #file, line: UInt = #line) -> Binds {
    var binds: Binds = .init()
    XCTAssertEqual(GeneralSQLSerializer.shared.serialize(query: query, binds: &binds), sql, file: file, line: line)
    return binds
}
