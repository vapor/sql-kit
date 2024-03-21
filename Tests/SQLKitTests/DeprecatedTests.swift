import SQLKit
import XCTest

@available(*, deprecated, message: "Contains tests of deprecated functionality")
final class SQLDeprecatedTests: XCTestCase {
    var db = TestDatabase()

    override class func setUp() {
        XCTAssert(isLoggingConfigured)
    }
    
    func testConcatOperator() {
        XCTAssertSerialization(of: self.db.raw("\(SQLBinaryOperator.concatenate)"), is: "")
    }
    
    func testSQLError() {
        struct RidiculousError: SQLError {
            var sqlErrorType: SQLErrorType
        }
        XCTAssertThrowsError(try { throw RidiculousError(sqlErrorType: .constraint) }()) { XCTAssertEqual(($0 as? any SQLError)?.sqlErrorType, .constraint) }
        XCTAssertThrowsError(try { throw RidiculousError(sqlErrorType: .io) }()) { XCTAssertEqual(($0 as? any SQLError)?.sqlErrorType, .io) }
        XCTAssertThrowsError(try { throw RidiculousError(sqlErrorType: .permission) }()) { XCTAssertEqual(($0 as? any SQLError)?.sqlErrorType, .permission) }
        XCTAssertThrowsError(try { throw RidiculousError(sqlErrorType: .syntax) }()) { XCTAssertEqual(($0 as? any SQLError)?.sqlErrorType, .syntax) }
        XCTAssertThrowsError(try { throw RidiculousError(sqlErrorType: .unknown) }()) { XCTAssertEqual(($0 as? any SQLError)?.sqlErrorType, .unknown) }
    }
    
    func testOldTriggerTimingSpecifiers() {
        XCTAssertEqual(SQLCreateTrigger.TimingSpecifier.initiallyImmediate, .deferrable)
        XCTAssertEqual(SQLCreateTrigger.TimingSpecifier.initiallyDeferred, .deferredByDefault)
    }
    
    func testDataTypeType() {
        XCTAssertSerialization(of: self.db.raw("\(SQLDataType.type("FOO"))"), is: "``FOO``")
    }
    
    func testOldCascadeProperties() {
        var dropEnum = SQLDropEnum(name: SQLIdentifier("enum"))
        
        dropEnum.cascade = false
        XCTAssertEqual(dropEnum.dropBehavior, .restrict)
        XCTAssertEqual(dropEnum.cascade, false)
        dropEnum.cascade = true
        XCTAssertEqual(dropEnum.dropBehavior, .cascade)
        XCTAssertEqual(dropEnum.cascade, true)

        var dropTrigger = SQLDropTrigger(name: SQLIdentifier("trigger"))
        
        dropTrigger.cascade = false
        XCTAssertEqual(dropTrigger.dropBehavior, .restrict)
        XCTAssertEqual(dropTrigger.cascade, false)
        dropTrigger.cascade = true
        XCTAssertEqual(dropTrigger.dropBehavior, .cascade)
        XCTAssertEqual(dropTrigger.cascade, true)
    }
    
    func testOldQueryStringInterpolations() {
        XCTAssertSerialization(of: self.db.raw("\(raw: "X") \("x")"), is: "X x")
    }
    
    func testRawBinds() {
        let raw = SQLRaw("SQL", ["a", "b"])
        XCTAssertEqual(raw.sql, "SQL")
        XCTAssertEqual(raw.binds[0] as? String, "a")
        XCTAssertEqual(raw.binds[1] as? String, "b")
    }
    
    func testOldUnionJoiner() {
        XCTAssertEqual(SQLUnionJoiner(all: true).type, .unionAll)
        XCTAssertEqual(SQLUnionJoiner(all: false).type, .union)
        XCTAssertEqual(SQLUnionJoiner(all: true).all, true)
        XCTAssertEqual(SQLUnionJoiner(all: false).all, false)
        
        var joiner1 = SQLUnionJoiner(type: .union)
        joiner1.all = true
        XCTAssertEqual(joiner1.type, .unionAll)
        joiner1.all = true // This is not a copy-paste error; it adds coverage of the default case in the switch.
        joiner1.all = false
        XCTAssertEqual(joiner1.type, .union)

        var joiner2 = SQLUnionJoiner(type: .intersect)
        joiner2.all = true
        XCTAssertEqual(joiner2.type, .intersectAll)
        joiner2.all = false
        XCTAssertEqual(joiner2.type, .intersect)

        var joiner3 = SQLUnionJoiner(type: .except)
        joiner3.all = true
        XCTAssertEqual(joiner3.type, .exceptAll)
        joiner3.all = false
        XCTAssertEqual(joiner3.type, .except)
    }
    
    func testColumnWithTable() {
        XCTAssertSerialization(of: self.db.select().column(table: "a", column: "b"), is: "SELECT ``a``.``b``")
    }
    
    func testAlterTableBuilderColumns() {
        XCTAssertNotNil(self.db.alter(table: "foo").column("a", type: .bigint).columns.first)
        let builder = self.db.alter(table: "foo").column("a", type: .bigint)
        builder.columns = [SQLColumnDefinition("a", dataType: .blob)]
    }
    
    func testCreateTriggerBuilderMethods() {
        XCTAssertNotNil(self.db.create(trigger: "a", table: "b", when: .after, event: .delete).condition("a").body(["b"]))
    }
    
    func testJoinBuilderMethod() {
        XCTAssertNotNil(self.db.select().join("a", method: .inner, on: "a"))
    }
}
