import SQLKit
import SQLKitBenchmark
import XCTest

final class SQLKitTriggerTests: XCTestCase {
    private let body = [
        "IF NEW.amount < 0 THEN",
        "SET NEW.amount = 0;",
        "END IF;",
    ]

    private var db: TestDatabase!

    override func setUp() {
        super.setUp()
        self.db = TestDatabase()
    }

    private func bodyText() -> String {
        body.joined(separator: " ")
    }

    func testDropTriggerOptions() throws {
        var dialect = GenericDialect()
        dialect.dropTriggerSupportsCascade = true
        dialect.dropTriggerSupportsTableName = true
        db._dialect = dialect

        try db.drop(trigger: "foo").table("planets").run().wait()
        XCTAssertEqual(db.results.popLast(), "DROP TRIGGER `foo` ON `planets`")

        try db.drop(trigger: "foo").table("planets").ifExists().run().wait()
        XCTAssertEqual(db.results.popLast(), "DROP TRIGGER IF EXISTS `foo` ON `planets`")

        try db.drop(trigger: "foo").table("planets").ifExists().cascade().run().wait()
        XCTAssertEqual(db.results.popLast(), "DROP TRIGGER IF EXISTS `foo` ON `planets` CASCADE")

        db._dialect.supportsIfExists = false
        try db.drop(trigger: "foo").table("planets").ifExists().run().wait()
        XCTAssertEqual(db.results.popLast(), "DROP TRIGGER `foo` ON `planets`")

        db._dialect.dropTriggerSupportsTableName = false
        try db.drop(trigger: "foo").table("planets").run().wait()
        XCTAssertEqual(db.results.popLast(), "DROP TRIGGER `foo`")

        db._dialect.dropTriggerSupportsCascade = false
        try db.drop(trigger: "foo").table("planets").ifExists().cascade().run().wait()
        XCTAssertEqual(db.results.popLast(), "DROP TRIGGER `foo`")
    }

    func testMySqlTriggerCreates() throws {
        var dialect = GenericDialect()
        dialect.createTriggerSupportsBody = true
        dialect.createTriggerRequiresForEachRow = true
        dialect.createTriggerSupportsOrder = true

        db._dialect = dialect

        try db.create(trigger: "foo", table: "planet", when: .before, event: .insert)
            .body(body)
            .order(.precedes)
            .orderTriggerName("other")
            .run().wait()
        XCTAssertEqual(db.results.popLast(), "CREATE TRIGGER `foo` BEFORE INSERT ON `planet` FOR EACH ROW PRECEDES `other` BEGIN \(bodyText()) END;")
    }

    func testSqliteTriggerCreates() throws {
        var dialect = GenericDialect()
        dialect.createTriggerSupportsBody = true
        dialect.createTriggerSupportsCondition = true

        db._dialect = dialect

        try db.create(trigger: "foo", table: "planet", when: .before, event: .insert)
            .body(body)
            .condition("foo = bar")
            .run().wait()
        XCTAssertEqual(db.results.popLast(), "CREATE TRIGGER `foo` BEFORE INSERT ON `planet` WHEN foo = bar BEGIN \(bodyText()) END;")
    }

    func testPostgreSqlTriggerCreates() throws {
        var dialect = GenericDialect()
        dialect.createTriggerSupportsForEach = true
        dialect.createTriggerPostgreSqlChecks = true
        dialect.createTriggerSupportsCondition = true
        dialect.createTriggerConditionRequiresParens = true
        dialect.createTriggerSupportsConstraint = true

        db._dialect = dialect

        try db.create(trigger: "foo", table: "planet", when: .after, event: .insert)
            .each(.row)
            .isConstraint()
            .timing(.initiallyDeferred)
            .condition("foo = bar")
            .procedure("qwer")
            .referencedTable(SQLIdentifier("galaxies"))
            .run().wait()

        XCTAssertEqual(db.results.popLast(), "CREATE CONSTRAINT TRIGGER `foo` AFTER INSERT ON `planet` FROM `galaxies` INITIALLY DEFERRED FOR EACH ROW WHEN (foo = bar) EXECUTE PROCEDURE `qwer`")
    }
}
