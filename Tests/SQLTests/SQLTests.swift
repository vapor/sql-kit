import XCTest
@testable import SQL

final class SQLTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SQL().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
