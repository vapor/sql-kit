@testable import SQLKit
import struct Logging.Logger
import protocol NIOCore.EventLoop
import class NIOCore.EventLoopFuture
import SQLKitBenchmark
import Testing

@Suite("Base tests")
struct BaseTests {
    init() {
        #expect(isLoggingConfigured)
    }

    // MARK: SQLBenchmark

    @Test("benchmark")
    func benchmark() async throws {
        let db = TestDatabase()
        let benchmarker = SQLBenchmarker(on: db)
        
        try await benchmarker.runAllTests()
    }
    
    // MARK: Operators
    
    @Test("binary operators")
    func binaryOperators() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.update("planets")
                .set(SQLIdentifier("moons"), to: SQLBinaryExpression(
                    left: SQLIdentifier("moons"),
                    op: SQLBinaryOperator.add,
                    right: SQLLiteral.numeric("1")
                ))
                .where("best_at_space", .greaterThanOrEqual, "yes"),
            is: "UPDATE ``planets`` SET ``moons`` = ``moons`` + 1 WHERE ``best_at_space`` >= &1"
        )
    }
    
    @Test("insert with array of Encodable")
    func insertWithArrayOfEncodable() {
        let db = TestDatabase()

        func weird(_ builder: SQLInsertBuilder, values: some Sequence<any Encodable & Sendable>) -> SQLInsertBuilder {
            builder.values(Array(values))
        }
        
        let output = weird(
            db.insert(into: "planets").columns("name"),
            values: ["Jupiter"]
        ).advancedSerialize()
        #expect(output.sql == "INSERT INTO ``planets`` (``name``) VALUES (&1)")
        #expect(output.binds as? [String] == ["Jupiter"]) // instead of [["Jupiter"]]
    }

    // MARK: JSON paths

    @Test("JSON paths")
    func JSONPaths() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select()
                .column(SQLNestedSubpathExpression(column: "json", path: ["a"]))
                .column(SQLNestedSubpathExpression(column: "json", path: ["a", "b"]))
                .column(SQLNestedSubpathExpression(column: "json", path: ["a", "b", "c"]))
                .column(SQLNestedSubpathExpression(column: SQLColumn("json", table: "table"), path: ["a", "b"])),
            is: "SELECT (``json``-»»'a'), (``json``-»'a'-»»'b'), (``json``-»'a'-»'b'-»»'c'), (``table``.``json``-»'a'-»»'b')"
        )
    }
    
    // MARK: Misc
        
    @Test("quoting")
    func quoting() throws {
        let db = TestDatabase()

        try expectSerialization(of: SQLRawBuilder("\(ident: "foo``bar``") \(literal: "foo'bar'")", on: db), is: "``foo````bar`````` 'foo''bar'''")
    }
    
    @Test("string handling utilities")
    func stringHandlingUtilities() {
        /// `encapitalized`
        #expect("".encapitalized == "")
        #expect("a".encapitalized == "A")
        #expect("A".encapitalized == "A")
        #expect("aa".encapitalized == "Aa")
        #expect("Aa".encapitalized == "Aa")
        #expect("aA".encapitalized == "AA")
        #expect("AA".encapitalized == "AA")

        /// `decapitalized`
        #expect("".decapitalized == "")
        #expect("a".decapitalized == "a")
        #expect("A".decapitalized == "a")
        #expect("aa".decapitalized == "aa")
        #expect("Aa".decapitalized == "aa")
        #expect("aA".decapitalized == "aA")
        #expect("AA".decapitalized == "aA")

        /// `convertedFromSnakeCase`
        #expect("".convertedFromSnakeCase == "")
        #expect("_".convertedFromSnakeCase == "_")
        #expect("__".convertedFromSnakeCase == "__")
        #expect("a".convertedFromSnakeCase == "a")
        #expect("a_".convertedFromSnakeCase == "a_")
        #expect("a_a".convertedFromSnakeCase == "aA")
        #expect("aA_a".convertedFromSnakeCase == "aAA")
        #expect("_a".convertedFromSnakeCase == "_a")
        #expect("_a_".convertedFromSnakeCase == "_a_")
        #expect("a_b_c".convertedFromSnakeCase == "aBC")
        #expect("_a_b_c_".convertedFromSnakeCase == "_aBC_")
        #expect("_a_b_bcc_".convertedFromSnakeCase == "_aBBcc_")

        /// `convertedToSnakeCase`
        #expect("".convertedToSnakeCase == "")
        #expect("_".convertedToSnakeCase == "_")
        #expect("__".convertedToSnakeCase == "__")
        #expect("a".convertedToSnakeCase == "a")
        #expect("a_".convertedToSnakeCase == "a_")
        #expect("aA".convertedToSnakeCase == "a_a")
        #expect("aAA".convertedToSnakeCase == "a_aA")
        #expect("_a".convertedToSnakeCase == "_a")
        #expect("_a_".convertedToSnakeCase == "_a_")
        #expect("aBC".convertedToSnakeCase == "a_bC")
        #expect("_aBC_".convertedToSnakeCase == "_a_bC_")
        #expect("aBBcc".convertedToSnakeCase == "a_b_bcc")
        #expect("_aBBcc_".convertedToSnakeCase == "_a_b_bcc_")
        
        /// `sqlkit_firstRange(of:)`
        #expect("a".sqlkit_firstRange(of: "abc") == nil)
        #expect("abba".sqlkit_firstRange(of: "abc") == nil)
        #expect("abc".sqlkit_firstRange(of: "abc") == "abc".startIndex ..< "abc".endIndex)
        #expect("aabca".sqlkit_firstRange(of: "abc") == "aabca".index(after: "aabca".startIndex) ..< "aabca".index(before: "aabca".endIndex))
        #expect("abcabc".sqlkit_firstRange(of: "abc") == "abcabc".startIndex ..< "abcabc".index("abcabc".startIndex, offsetBy: 3))
        #expect("aabc_abca".sqlkit_firstRange(of: "abc") == "aabc_abca".index(after: "aabc_abca".startIndex) ..< "aabc_abca".index("aabc_abca".startIndex, offsetBy: 4))

        /// `sqlkit_replacing(_:with:)`
        #expect("abc".sqlkit_replacing("abc", with: "def") == "def")
        #expect("aabca".sqlkit_replacing("abc", with: "def") == "adefa")
        #expect("abcabc".sqlkit_replacing("abc", with: "def") == "defdef")
        #expect("aabc_abca".sqlkit_replacing("abc", with: "def") == "adef_defa")

        /// `codingKeyValue`
        #expect("a".codingKeyValue.stringValue == "a")
        
        /// `drop(prefix:)`
        #expect("abcdef".drop(prefix: "abc") == "def")
        #expect("acbdef".drop(prefix: "abc") == "acbdef")
        #expect("abcdef".drop(prefix: String?.none) == "abcdef")
    }
    
    @Test("database default properties")
    func databaseDefaultProperties() {
        let db = TestDatabase()

        #expect(db.version == nil)
        #expect(db.queryLogLevel == .debug)
    }
    
    @Test("logger database")
    func loggerDatabase() async throws {
        let sdb = TestDatabase()
        let db = sdb.logging(to: .init(label: "l"))

        #expect(db.version == nil)
        #expect(db.logger.logLevel == Logger(label: "l").logLevel)
        #expect(ObjectIdentifier(db.eventLoop) == ObjectIdentifier(sdb.eventLoop))
        #expect(db.dialect.name == db.dialect.name)
        #expect(db.queryLogLevel == db.queryLogLevel)
        await #expect(throws: Never.self) { try await db.execute(sql: SQLRaw("TEST"), { _ in }) }
        await #expect(throws: Never.self) { try await db.execute(sql: SQLRaw("TEST"), { _ in }).get() }
    }
    
    @Test("database default async impl")
    func databaseDefaultAsyncImpl() async throws {
        await #expect(throws: Never.self) { try await TestNoAsyncDatabase().execute(sql: SQLRaw("TEST"), { _ in }) }
    }

    @Test("database version")
    func databaseVersion() {
        struct TestVersion: SQLDatabaseReportedVersion {
            let stringValue: String
        }
        struct AnotherTestVersion: SQLDatabaseReportedVersion {
            let stringValue: String
        }
        
        #expect(TestVersion(stringValue: "a") == TestVersion(stringValue: "a"))
        #expect(!TestVersion(stringValue: "a").isEqual(to: AnotherTestVersion(stringValue: "a")))
        #expect(TestVersion(stringValue: "a") != TestVersion(stringValue: "b"))
        #expect(TestVersion(stringValue: "a") < TestVersion(stringValue: "b"))
        #expect(!TestVersion(stringValue: "a").isOlder(than: AnotherTestVersion(stringValue: "a")))
        #expect(TestVersion(stringValue: "a") <= TestVersion(stringValue: "a"))
        #expect(TestVersion(stringValue: "b") > TestVersion(stringValue: "a"))
        #expect(TestVersion(stringValue: "a") >= TestVersion(stringValue: "a"))
    }
    
    @Test("database with session")
    func databaseWithSession() async throws {
        let db = TestDatabase()

        #expect(try await db.withSession { _ in true })
    }
    
    @Test("dialect default implementations")
    func dialectDefaultImplementations() {
        struct TestDialect: SQLDialect {
            var name: String { "test" }
            var identifierQuote: any SQLExpression { SQLRaw("`") }
            var supportsAutoIncrement: Bool { false }
            var autoIncrementClause: any SQLExpression { SQLRaw("") }
            func bindPlaceholder(at position: Int) -> any SQLExpression { SQLLiteral.numeric("\(position)") }
            func literalBoolean(_ value: Bool) -> any SQLExpression { SQLRaw("\(value)") }
        }
        
        #expect((TestDialect().literalStringQuote as? SQLRaw)?.sql == "'")
        #expect(TestDialect().autoIncrementFunction == nil)
        #expect((TestDialect().literalDefault as? SQLRaw)?.sql == "DEFAULT")
        #expect(TestDialect().supportsIfExists)
        #expect(TestDialect().enumSyntax == .unsupported)
        #expect(!TestDialect().supportsDropBehavior)
        #expect(!TestDialect().supportsReturning)
        #expect(TestDialect().triggerSyntax.create == [])
        #expect(TestDialect().triggerSyntax.drop == [])
        #expect(TestDialect().alterTableSyntax.alterColumnDefinitionClause == nil)
        #expect(TestDialect().alterTableSyntax.alterColumnDefinitionTypeKeyword == nil)
        #expect(TestDialect().alterTableSyntax.allowsBatch)
        #expect(TestDialect().customDataType(for: .int) == nil)
        #expect((TestDialect().normalizeSQLConstraint(identifier: SQLRaw("")) as? SQLRaw)?.sql == "")
        #expect(TestDialect().upsertSyntax == .unsupported)
        #expect(TestDialect().unionFeatures == [.union, .unionAll])
        #expect(TestDialect().sharedSelectLockExpression == nil)
        #expect(TestDialect().exclusiveSelectLockExpression == nil)
        #expect(TestDialect().nestedSubpathExpression(in: SQLRaw(""), for: [""]) == nil)
    }
    
    @Test("additional SQLStatement API")
    func additionalSQLStatementAPI() {
        let db = TestDatabase()
        var serializer = SQLSerializer(database: db)
        serializer.statement {
            $0.append("a")
            $0.append(SQLRaw("a"))
            
            $0.append("a", "b")
            $0.append(SQLRaw("a"), "b")
            $0.append("a", SQLRaw("b"))
            $0.append(SQLRaw("a"), SQLRaw("b"))
            
            $0.append("a", "b", "c")
            $0.append(SQLRaw("a"), "b", "c")
            $0.append("a", SQLRaw("b"), "c")
            $0.append("a", "b", SQLRaw("c"))
            $0.append(SQLRaw("a"), SQLRaw("b"), "c")
            $0.append(SQLRaw("a"), "b", SQLRaw("c"))
            $0.append("a", SQLRaw("b"), SQLRaw("c"))
            $0.append(SQLRaw("a"), SQLRaw("b"), SQLRaw("c"))
        }
        #expect(serializer.sql == "a a a b a b a b a b a b c a b c a b c a b c a b c a b c a b c a b c")
    }
}
