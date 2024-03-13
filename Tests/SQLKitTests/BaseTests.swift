import SQLKit
import SQLKitBenchmark
import XCTest

final class SQLKitTests: XCTestCase {
    var db = TestDatabase()

    override class func setUp() {
        XCTAssert(isLoggingConfigured)
    }
    
    // MARK: SQLBenchmark

    func testBenchmark() async throws {
        let benchmarker = SQLBenchmarker(on: db)
        
        try await benchmarker.runAll()
    }
    
    // MARK: Operators
    
    func testBinaryOperators() {
        XCTAssertSerialization(
            of: self.db.update("planets")
                .set(SQLIdentifier("moons"), to: SQLBinaryExpression(
                    left: SQLIdentifier("moons"),
                    op: SQLBinaryOperator.add,
                    right: SQLLiteral.numeric("1")
                ))
                .where("best_at_space", .greaterThanOrEqual, "yes"),
            is: "UPDATE `planets` SET `moons` = `moons` + 1 WHERE `best_at_space` >= ?"
        )
    }
    
    func testInsertWithArrayOfEncodable() {
        func weird(_ builder: SQLInsertBuilder, values: some Sequence<Encodable & Sendable>) -> SQLInsertBuilder {
            builder.values(Array(values))
        }
        
        let output = XCTAssertNoThrowWithResult(weird(
                self.db.insert(into: "planets").columns("name"),
                values: ["Jupiter"]
            )
            .advancedSerialize()
        )
        XCTAssertEqual(output?.sql, "INSERT INTO `planets` (`name`) VALUES (?)")
        XCTAssertEqual(output?.binds as? [String], ["Jupiter"]) // instead of [["Jupiter"]]
    }

    // MARK: JSON paths

    func testJSONPaths() {
        XCTAssertSerialization(
            of: self.db.select()
                .column(SQLNestedSubpathExpression(column: "json", path: ["a"]))
                .column(SQLNestedSubpathExpression(column: "json", path: ["a", "b"]))
                .column(SQLNestedSubpathExpression(column: "json", path: ["a", "b", "c"]))
                .column(SQLNestedSubpathExpression(column: SQLColumn("json", table: "table"), path: ["a", "b"])),
            is: "SELECT (`json`->>'a'), (`json`->'a'->>'b'), (`json`->'a'->'b'->>'c'), (`table`.`json`->'a'->>'b')"
        )
    }
}
