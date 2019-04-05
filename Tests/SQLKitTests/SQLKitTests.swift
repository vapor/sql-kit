import SQLKit
import SQLKitBenchmark
import XCTest

final class SQLKitTests: XCTestCase {
    func testBenchmarker() throws {
        let db = TestDatabase()
        let benchmarker = SQLBenchmarker(on: db)
        try benchmarker.run()
    }
    
    func testLockingClause_forUpdate() throws {
        let db = TestDatabase()
        try db.select().column("*")
            .from("planets")
            .where("name", .equal, "Earth")
            .for(.update)
            .run().wait()
        XCTAssertEqual(db.results[0], "SELECT * FROM `planets` WHERE `name` = ? FOR UPDATE")
    }
    
    func testLockingClause_lockInShareMode() throws {
        let db = TestDatabase()
        try db.select().column("*")
            .from("planets")
            .where("name", .equal, "Earth")
            .lockingClause(SQLRaw("LOCK IN SHARE MODE"))
            .run().wait()
        XCTAssertEqual(db.results[0], "SELECT * FROM `planets` WHERE `name` = ? LOCK IN SHARE MODE")
    }
    
    func testRawQueryStringInterpolation() throws {
        let db = TestDatabase()
        let builder = db.raw2("SELECT * FROM planets WHERE name = \("Earth")")
        var serializer = SQLSerializer(dialect: GenericDialect())
        builder.query.serialize(to: &serializer)
        
        XCTAssertEqual(serializer.sql, "SELECT * FROM planets WHERE name = ?")
        XCTAssert(serializer.binds.first! as! String == "Earth")
    }
}
