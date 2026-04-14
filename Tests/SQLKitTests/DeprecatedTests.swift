import SQLKit
import Testing

@Suite("Deprecated functionality tests")
struct DeprecatedTests {
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
    @Test("concat operator")
    func concatOperator() throws {
        let db = TestDatabase()

        try expectSerialization(of: db.raw("\(SQLBinaryOperator.concatenate)"), is: "")
    }
    
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
    @Test("SQLError")
    func sqlError() {
        struct RidiculousError: SQLError {
            var sqlErrorType: SQLErrorType
        }
         #expect(((#expect(throws: (any Error).self) { throw RidiculousError(sqlErrorType: .constraint) }) as? any SQLError)?.sqlErrorType == .constraint)
         #expect(((#expect(throws: (any Error).self) { throw RidiculousError(sqlErrorType: .io) }) as? any SQLError)?.sqlErrorType == .io)
         #expect(((#expect(throws: (any Error).self) { throw RidiculousError(sqlErrorType: .permission) }) as? any SQLError)?.sqlErrorType == .permission)
         #expect(((#expect(throws: (any Error).self) { throw RidiculousError(sqlErrorType: .syntax) }) as? any SQLError)?.sqlErrorType == .syntax)
         #expect(((#expect(throws: (any Error).self) { throw RidiculousError(sqlErrorType: .unknown) }) as? any SQLError)?.sqlErrorType == .unknown)
    }
    
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
    @Test("old trigger timing specifiers")
    func oldTriggerTimingSpecifiers() {
        #expect(SQLCreateTrigger.TimingSpecifier.initiallyImmediate == .deferrable)
        #expect(SQLCreateTrigger.TimingSpecifier.initiallyDeferred == .deferredByDefault)
    }
    
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
    @Test("SQLDataType type")
    func sqlDataTypeType() throws {
        let db = TestDatabase()

        try expectSerialization(of: db.raw("\(SQLDataType.type("FOO"))"), is: "``FOO``")
    }
    
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
    @Test("old cascade properties")
    func oldCascadeProperties() {
        var dropEnum = SQLDropEnum(name: SQLIdentifier("enum"))
        
        dropEnum.cascade = false
        #expect(dropEnum.dropBehavior == .restrict)
        #expect(dropEnum.cascade == false)
        dropEnum.cascade = true
        #expect(dropEnum.dropBehavior == .cascade)
        #expect(dropEnum.cascade == true)

        var dropTrigger = SQLDropTrigger(name: SQLIdentifier("trigger"))
        
        dropTrigger.cascade = false
        #expect(dropTrigger.dropBehavior == .restrict)
        #expect(dropTrigger.cascade == false)
        dropTrigger.cascade = true
        #expect(dropTrigger.dropBehavior == .cascade)
        #expect(dropTrigger.cascade == true)
    }
    
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
    @Test("old SQLQueryString interpolations")
    func oldSQLQueryStringInterpolations() throws {
        let db = TestDatabase()

        try expectSerialization(of: db.raw("\(raw: "X") \("x")"), is: "X x")
    }
    
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
    @Test("raw binds")
    func rawBinds() {
        let raw = SQLRaw("SQL", ["a", "b"])
        #expect(raw.sql == "SQL")
        #expect(raw.binds[0] as? String == "a")
        #expect(raw.binds[1] as? String == "b")
    }
    
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
    @Test("old union joiner")
    func oldUnionJoiner() {
        #expect(SQLUnionJoiner(all: true).type == .unionAll)
        #expect(SQLUnionJoiner(all: false).type == .union)
        #expect(SQLUnionJoiner(all: true).all == true)
        #expect(SQLUnionJoiner(all: false).all == false)
        
        var joiner1 = SQLUnionJoiner(type: .union)
        joiner1.all = true
        #expect(joiner1.type == .unionAll)
        joiner1.all = true // This is not a copy-paste error; it adds coverage of the default case in the switch.
        joiner1.all = false
        #expect(joiner1.type == .union)

        var joiner2 = SQLUnionJoiner(type: .intersect)
        joiner2.all = true
        #expect(joiner2.type == .intersectAll)
        joiner2.all = false
        #expect(joiner2.type == .intersect)

        var joiner3 = SQLUnionJoiner(type: .except)
        joiner3.all = true
        #expect(joiner3.type == .exceptAll)
        joiner3.all = false
        #expect(joiner3.type == .except)
    }
    
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
    @Test("column with table")
    func columnWithTable() throws {
        let db = TestDatabase()

        try expectSerialization(of: db.select().column(table: "a", column: "b"), is: "SELECT ``a``.``b``")
    }
    
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
    @Test("ALTER TABLE builder columns")
    func alterTableBuilderColumns() {
        let db = TestDatabase()

        #expect(db.alter(table: "foo").column("a", type: .bigint).columns.first != nil)
        let builder = db.alter(table: "foo").column("a", type: .bigint)
        builder.columns = [SQLColumnDefinition("a", dataType: .blob)]
    }
    
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
    @Test("CREATE TRIGGER builder methods")
    func createTriggerBuilderMethods() {
        let db = TestDatabase()

        #expect(db.create(trigger: "a", table: "b", when: .after, event: .delete).condition("a").body(["b"]).createTrigger.name is SQLIdentifier)
    }
    
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
    @Test("JOIN builder method")
    func joinBuilderMethod() {
        let db = TestDatabase()

        #expect(!db.select().join("a", method: .inner, on: "a").select.joins.isEmpty)
    }
    
    @available(*, deprecated, message: "Contains tests of deprecated functionality")
    @Test("obsolete version comparators")
    func obsoleteVersionComparators() {
        struct TestVersion: SQLDatabaseReportedVersion { let stringValue: String }
        struct AnotherTestVersion: SQLDatabaseReportedVersion { let stringValue: String }

        /// `>`
        #expect(TestVersion(stringValue: "b").isNewer(than: TestVersion(stringValue: "a")))
        #expect(!TestVersion(stringValue: "b").isNewer(than: AnotherTestVersion(stringValue: "a")))
        
        /// `<=`
        #expect(TestVersion(stringValue: "a").isNotNewer(than: TestVersion(stringValue: "b")))
        #expect(TestVersion(stringValue: "a").isNotNewer(than: TestVersion(stringValue: "a")))
        #expect(!TestVersion(stringValue: "a").isNotNewer(than: AnotherTestVersion(stringValue: "a")))
        
        /// `<`
        #expect(TestVersion(stringValue: "a").isOlder(than: TestVersion(stringValue: "b")))
        #expect(!TestVersion(stringValue: "a").isOlder(than: AnotherTestVersion(stringValue: "b")))
        
        /// `>=`
        #expect(TestVersion(stringValue: "b").isNotOlder(than: TestVersion(stringValue: "a")))
        #expect(TestVersion(stringValue: "a").isNotOlder(than: TestVersion(stringValue: "a")))
        #expect(!TestVersion(stringValue: "b").isNotOlder(than: AnotherTestVersion(stringValue: "a")))
    }
}
