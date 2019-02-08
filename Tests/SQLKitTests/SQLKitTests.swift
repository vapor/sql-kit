import SQLKit
import SQLKitBenchmark
import XCTest

final class SQLKitTests: XCTestCase {
    func testBenchmarker() throws {
        let db = TestDatabase()
        let benchmarker = SQLBenchmarker(on: db)
        try benchmarker.run()
    }
    
    func testLockingClause() throws {
        let db = TestDatabase()
        try db.select().column("*")
            .from("planets")
            .where("name", .equal, "Earth")
            .for(.update)
            .run().wait()
        XCTAssertEqual(db.results[0], "SELECT * FROM `planets` WHERE `name` = ? FOR UPDATE")
    }
}
