import SQLKit
import XCTest

final class SQLDeprecatedTests: XCTestCase {
    var db = TestDatabase()

    override class func setUp() {
        XCTAssert(isLoggingConfigured)
    }
    
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
    func testConcatOperator() {
        XCTAssertSerialization(of: self.db.raw("\(SQLBinaryOperator.concatenate)"), is: "")
    }
    
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
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
    
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
    func testOldTriggerTimingSpecifiers() {
        XCTAssertEqual(SQLCreateTrigger.TimingSpecifier.initiallyImmediate, .deferrable)
        XCTAssertEqual(SQLCreateTrigger.TimingSpecifier.initiallyDeferred, .deferredByDefault)
    }
    
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
    func testDataTypeType() {
        XCTAssertSerialization(of: self.db.raw("\(SQLDataType.type("FOO"))"), is: "``FOO``")
    }
    
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
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
    
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
    func testOldQueryStringInterpolations() {
        XCTAssertSerialization(of: self.db.raw("\(raw: "X") \("x")"), is: "X x")
    }
    
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
    func testRawBinds() {
        let raw = SQLUnsafeRaw("SQL", ["a", "b"])
        XCTAssertEqual(raw.sql, "SQL")
        XCTAssertEqual(raw.binds[0] as? String, "a")
        XCTAssertEqual(raw.binds[1] as? String, "b")
    }
    
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
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
    
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
    func testColumnWithTable() {
        XCTAssertSerialization(of: self.db.select().column(table: "a", column: "b"), is: "SELECT ``a``.``b``")
    }
    
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
    func testAlterTableBuilderColumns() {
        XCTAssertNotNil(self.db.alter(table: "foo").column("a", type: .bigint).columns.first)
        let builder = self.db.alter(table: "foo").column("a", type: .bigint)
        builder.columns = [SQLColumnDefinition("a", dataType: .blob)]
    }
    
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
    func testCreateTriggerBuilderMethods() {
        XCTAssertNotNil(self.db.create(trigger: "a", table: "b", when: .after, event: .delete).condition("a").body(["b"]))
    }
    
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
    func testJoinBuilderMethod() {
        XCTAssertNotNil(self.db.select().join("a", method: .inner, on: "a"))
    }
    
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
    func testObsoleteVersionComparators() {
        struct TestVersion: SQLDatabaseReportedVersion { let stringValue: String }
        struct AnotherTestVersion: SQLDatabaseReportedVersion { let stringValue: String }

        /// `>`
        XCTAssert(TestVersion(stringValue: "b").isNewer(than: TestVersion(stringValue: "a")))
        XCTAssertFalse(TestVersion(stringValue: "b").isNewer(than: AnotherTestVersion(stringValue: "a")))
        
        /// `<=`
        XCTAssert(TestVersion(stringValue: "a").isNotNewer(than: TestVersion(stringValue: "b")))
        XCTAssert(TestVersion(stringValue: "a").isNotNewer(than: TestVersion(stringValue: "a")))
        XCTAssertFalse(TestVersion(stringValue: "a").isNotNewer(than: AnotherTestVersion(stringValue: "a")))
        
        /// `<`
        XCTAssert(TestVersion(stringValue: "a").isOlder(than: TestVersion(stringValue: "b")))
        XCTAssertFalse(TestVersion(stringValue: "a").isOlder(than: AnotherTestVersion(stringValue: "b")))
        
        /// `>=`
        XCTAssert(TestVersion(stringValue: "b").isNotOlder(than: TestVersion(stringValue: "a")))
        XCTAssert(TestVersion(stringValue: "a").isNotOlder(than: TestVersion(stringValue: "a")))
        XCTAssertFalse(TestVersion(stringValue: "b").isNotOlder(than: AnotherTestVersion(stringValue: "a")))
    }
}
