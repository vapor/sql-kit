@testable import SQLKit
import protocol NIOCore.EventLoop
import class NIOCore.EventLoopFuture
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
            is: "UPDATE ``planets`` SET ``moons`` = ``moons`` + 1 WHERE ``best_at_space`` >= &1"
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
        XCTAssertEqual(output?.sql, "INSERT INTO ``planets`` (``name``) VALUES (&1)")
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
            is: "SELECT (``json``->>'a'), (``json``->'a'->>'b'), (``json``->'a'->'b'->>'c'), (``table``.``json``->'a'->>'b')"
        )
    }
    
    // MARK: Misc
    
    func testQuoting() {
        XCTAssertSerialization(of: SQLRawBuilder("\(ident: "foo``bar``") \(literal: "foo'bar'")", on: self.db), is: "``foo````bar`````` 'foo''bar'''")
    }
    
    func testStringHandlingUtilities() {
        /// `encapitalized`
        XCTAssertEqual("".encapitalized, "")
        XCTAssertEqual("a".encapitalized, "A")
        XCTAssertEqual("A".encapitalized, "A")
        XCTAssertEqual("aa".encapitalized, "Aa")
        XCTAssertEqual("Aa".encapitalized, "Aa")
        XCTAssertEqual("aA".encapitalized, "AA")
        XCTAssertEqual("AA".encapitalized, "AA")

        /// `decapitalized`
        XCTAssertEqual("".decapitalized, "")
        XCTAssertEqual("a".decapitalized, "a")
        XCTAssertEqual("A".decapitalized, "a")
        XCTAssertEqual("aa".decapitalized, "aa")
        XCTAssertEqual("Aa".decapitalized, "aa")
        XCTAssertEqual("aA".decapitalized, "aA")
        XCTAssertEqual("AA".decapitalized, "aA")

        /// `convertedFromSnakeCase`
        XCTAssertEqual("".convertedFromSnakeCase, "")
        XCTAssertEqual("_".convertedFromSnakeCase, "_")
        XCTAssertEqual("__".convertedFromSnakeCase, "__")
        XCTAssertEqual("a".convertedFromSnakeCase, "a")
        XCTAssertEqual("a_".convertedFromSnakeCase, "a_")
        XCTAssertEqual("a_a".convertedFromSnakeCase, "aA")
        XCTAssertEqual("aA_a".convertedFromSnakeCase, "aAA")
        XCTAssertEqual("_a".convertedFromSnakeCase, "_a")
        XCTAssertEqual("_a_".convertedFromSnakeCase, "_a_")
        XCTAssertEqual("a_b_c".convertedFromSnakeCase, "aBC")
        XCTAssertEqual("_a_b_c_".convertedFromSnakeCase, "_aBC_")
        XCTAssertEqual("_a_b_bcc_".convertedFromSnakeCase, "_aBBcc_")

        /// `convertedToSnakeCase`
        XCTAssertEqual("".convertedToSnakeCase, "")
        XCTAssertEqual("_".convertedToSnakeCase, "_")
        XCTAssertEqual("__".convertedToSnakeCase, "__")
        XCTAssertEqual("a".convertedToSnakeCase, "a")
        XCTAssertEqual("a_".convertedToSnakeCase, "a_")
        XCTAssertEqual("aA".convertedToSnakeCase, "a_a")
        XCTAssertEqual("aAA".convertedToSnakeCase, "a_aA")
        XCTAssertEqual("_a".convertedToSnakeCase, "_a")
        XCTAssertEqual("_a_".convertedToSnakeCase, "_a_")
        XCTAssertEqual("aBC".convertedToSnakeCase, "a_bC")
        XCTAssertEqual("_aBC_".convertedToSnakeCase, "_a_bC_")
        XCTAssertEqual("aBBcc".convertedToSnakeCase, "a_b_bcc")
        XCTAssertEqual("_aBBcc_".convertedToSnakeCase, "_a_b_bcc_")
        
        /// `sqlkit_firstRange(of:)`
        XCTAssertEqual("a".sqlkit_firstRange(of: "abc"), nil)
        XCTAssertEqual("abba".sqlkit_firstRange(of: "abc"), nil)
        XCTAssertEqual("abc".sqlkit_firstRange(of: "abc"), "abc".startIndex ..< "abc".endIndex)
        XCTAssertEqual("aabca".sqlkit_firstRange(of: "abc"), "aabca".index(after: "aabca".startIndex) ..< "aabca".index(before: "aabca".endIndex))
        XCTAssertEqual("abcabc".sqlkit_firstRange(of: "abc"), "abcabc".startIndex ..< "abcabc".index("abcabc".startIndex, offsetBy: 3))
        XCTAssertEqual("aabc_abca".sqlkit_firstRange(of: "abc"), "aabc_abca".index(after: "aabc_abca".startIndex) ..< "aabc_abca".index("aabc_abca".startIndex, offsetBy: 4))

        /// `sqlkit_replacing(_:with:)`
        XCTAssertEqual("abc".sqlkit_replacing("abc", with: "def"), "def")
        XCTAssertEqual("aabca".sqlkit_replacing("abc", with: "def"), "adefa")
        XCTAssertEqual("abcabc".sqlkit_replacing("abc", with: "def"), "defdef")
        XCTAssertEqual("aabc_abca".sqlkit_replacing("abc", with: "def"), "adef_defa")
        
        /// `codingKeyValue`
        XCTAssertEqual("a".codingKeyValue.stringValue, "a")
        
        /// `drop(prefix:)`
        XCTAssertEqual("abcdef".drop(prefix: "abc"), "def")
        XCTAssertEqual("acbdef".drop(prefix: "abc"), "acbdef")
        XCTAssertEqual("abcdef".drop(prefix: String?.none), "abcdef")
    }
    
    func testDatabaseDefaultProperties() {
        XCTAssertNil(self.db.version)
        XCTAssertEqual(self.db.queryLogLevel, .debug)
    }
    
    func testDatabaseLoggerDatabase() async throws {
        let db = self.db.logging(to: .init(label: "l"))
        
        XCTAssertNotNil(db.eventLoop)
        XCTAssertNil(db.version)
        XCTAssertEqual(db.dialect.name, self.db.dialect.name)
        XCTAssertEqual(db.queryLogLevel, self.db.queryLogLevel)
        await XCTAssertNotNilAsync(try await db.execute(sql: SQLRaw("TEST"), { _ in }))
        await XCTAssertNotNilAsync(try await db.execute(sql: SQLRaw("TEST"), { _ in }).get())
    }
    
    func testDatabaseDefaultAsyncImpl() async throws {
        struct TestNoAsyncDatabase: SQLDatabase {
            func execute(sql query: any SQLExpression, _ onRow: @escaping @Sendable (any SQLRow) -> ()) -> EventLoopFuture<Void> { self.eventLoop.makeSucceededVoidFuture() }
            var logger: Logging.Logger { .init(label: "l") }
            var eventLoop: any EventLoop { FakeEventLoop() }
            var dialect: any SQLDialect { GenericDialect() }
        }
        await XCTAssertNotNilAsync(try await TestNoAsyncDatabase().execute(sql: SQLRaw("TEST"), { _ in }))
    }

    func testDatabaseVersion() {
        struct TestVersion: SQLDatabaseReportedVersion {
            let stringValue: String
            
            func isEqual(to otherVersion: any SQLDatabaseReportedVersion) -> Bool { self.stringValue == otherVersion.stringValue }
            func isOlder(than otherVersion: any SQLDatabaseReportedVersion) -> Bool { self.stringValue.lexicographicallyPrecedes(otherVersion.stringValue) }
        }
        
        XCTAssert(TestVersion(stringValue: "a") == TestVersion(stringValue: "a"))
        XCTAssert(TestVersion(stringValue: "a") != TestVersion(stringValue: "b"))
        XCTAssert(TestVersion(stringValue: "a") < TestVersion(stringValue: "b"))
        XCTAssert(TestVersion(stringValue: "a") <= TestVersion(stringValue: "a"))
        XCTAssert(TestVersion(stringValue: "b") > TestVersion(stringValue: "a"))
        XCTAssert(TestVersion(stringValue: "a") >= TestVersion(stringValue: "a"))
    }
    
    func testDialectDefaultImpls() {
        struct TestDialect: SQLDialect {
            var name: String { "test" }
            var identifierQuote: any SQLExpression { SQLRaw("`") }
            var supportsAutoIncrement: Bool { false }
            var autoIncrementClause: any SQLExpression { SQLRaw("") }
            func bindPlaceholder(at position: Int) -> any SQLExpression { SQLLiteral.numeric("\(position)") }
            func literalBoolean(_ value: Bool) -> any SQLExpression { SQLRaw("\(value)") }
        }
        
        XCTAssertEqual((TestDialect().literalStringQuote as? SQLRaw)?.sql, "'")
        XCTAssertNil(TestDialect().autoIncrementFunction)
        XCTAssertEqual((TestDialect().literalDefault as? SQLRaw)?.sql, "DEFAULT")
        XCTAssert(TestDialect().supportsIfExists)
        XCTAssertEqual(TestDialect().enumSyntax, .unsupported)
        XCTAssertFalse(TestDialect().supportsDropBehavior)
        XCTAssertFalse(TestDialect().supportsReturning)
        XCTAssertEqual(TestDialect().triggerSyntax.create, [])
        XCTAssertEqual(TestDialect().triggerSyntax.drop, [])
        XCTAssertNil(TestDialect().alterTableSyntax.alterColumnDefinitionClause)
        XCTAssertNil(TestDialect().alterTableSyntax.alterColumnDefinitionTypeKeyword)
        XCTAssert(TestDialect().alterTableSyntax.allowsBatch)
        XCTAssertNil(TestDialect().customDataType(for: .int))
        XCTAssertEqual((TestDialect().normalizeSQLConstraint(identifier: SQLRaw("")) as? SQLRaw)?.sql, "")
        XCTAssertEqual(TestDialect().upsertSyntax, .unsupported)
        XCTAssertEqual(TestDialect().unionFeatures, [.union, .unionAll])
        XCTAssertNil(TestDialect().sharedSelectLockExpression)
        XCTAssertNil(TestDialect().exclusiveSelectLockExpression)
        XCTAssertNil(TestDialect().nestedSubpathExpression(in: SQLRaw(""), for: [""]))
    }
}
