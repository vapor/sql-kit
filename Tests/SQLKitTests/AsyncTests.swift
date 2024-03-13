import SQLKit
import XCTest

final class AsyncSQLKitTests: XCTestCase {
    var db = TestDatabase()

    override class func setUp() {
        XCTAssert(isLoggingConfigured)
    }
    
    func testSQLDatabaseAsync() async throws {
        try await self.db.execute(sql: SQLRaw("TEST"), { _ in XCTFail("Should not receive results") })
        XCTAssertEqual(self.db.results[0], "TEST")
    }
    
    func testSQLQueryBuilderAsync() async throws {
        try await self.db.update("a").set("b", to: "c").run()
        XCTAssertEqual(self.db.results[0], "UPDATE `a` SET `b` = ?")
    }
    
    func testSQLQueryFetcherAsync() async throws {
        try await self.db.select().column("a").from("b").run { _ in XCTFail("Should not receive results") }
        XCTAssertEqual(self.db.results[0], "SELECT `a` FROM `b`")
        
        try await self.db.select().column("a").from("b").run(decoding: [String: String].self, { _ in XCTFail("Should not receive results") })
        XCTAssertEqual(self.db.results[1], "SELECT `a` FROM `b`")
        
        let res1 = try await self.db.select().column("a").from("b").all()
        XCTAssert(res1.isEmpty)
        XCTAssertEqual(self.db.results[2], "SELECT `a` FROM `b`")

        let res2 = try await self.db.select().column("a").from("b").all(decoding: [String: String].self)
        XCTAssert(res2.isEmpty)
        XCTAssertEqual(self.db.results[3], "SELECT `a` FROM `b`")

        let res3 = try await self.db.select().column("a").from("b").first()
        XCTAssertNil(res3)
        XCTAssertEqual(self.db.results[4], "SELECT `a` FROM `b` LIMIT 1")

        let res4 = try await self.db.select().column("a").from("b").first(decoding: [String: String].self)
        XCTAssertNil(res4)
        XCTAssertEqual(self.db.results[5], "SELECT `a` FROM `b` LIMIT 1")
    }
}
