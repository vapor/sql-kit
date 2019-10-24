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
        let (table, planet) = ("planets", "Earth")
        let builder = db.raw("SELECT * FROM \(table) WHERE name = \(bind: planet)")
        var serializer = SQLSerializer(dialect: GenericDialect())
        builder.query.serialize(to: &serializer)

        XCTAssertEqual(serializer.sql, "SELECT * FROM planets WHERE name = ?")
        XCTAssert(serializer.binds.first! as! String == "Earth")
    }

    func testGroupByHaving() throws {
        let db = TestDatabase()
        try db.select().column("*")
            .from("planets")
            .groupBy("color")
            .having("color", .equal, "blue")
            .run().wait()
        XCTAssertEqual(db.results[0], "SELECT * FROM `planets` GROUP BY `color` HAVING `color` = ?")
    }

    func testIfExists() throws {
        let db = TestDatabase()

        try db.drop(table: "planets").ifExists().run().wait()
        XCTAssertEqual(db.results[0], "DROP TABLE IF EXISTS `planets`")

        db.dialect = GenericDialect(supportsIfExists: false)
        try db.drop(table: "planets").ifExists().run().wait()
        XCTAssertEqual(db.results[1], "DROP TABLE `planets`")
    }
}
