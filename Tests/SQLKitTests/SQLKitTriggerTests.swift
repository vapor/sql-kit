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
        dialect.setTriggerSyntax(drop: [.supportsCascade, .supportsTableName])
        debugPrint(dialect.triggerSyntax.drop)
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

        db._dialect.triggerSyntax.drop = .supportsCascade
        try db.drop(trigger: "foo").table("planets").run().wait()
        XCTAssertEqual(db.results.popLast(), "DROP TRIGGER `foo`")

        db._dialect.triggerSyntax.drop = []
        try db.drop(trigger: "foo").table("planets").ifExists().cascade().run().wait()
        XCTAssertEqual(db.results.popLast(), "DROP TRIGGER `foo`")
    }

    func testMySqlTriggerCreates() throws {
        var dialect = GenericDialect()
        dialect.setTriggerSyntax(create: [.supportsBody, .requiresForEachRow, .supportsOrder])

        db._dialect = dialect

        try db.create(trigger: "foo", table: "planet", when: .before, event: .insert)
            .body(self.body.map { SQLRaw($0) })
            .order(precedence: .precedes, otherTriggerName: "other")
            .run().wait()
        XCTAssertEqual(db.results.popLast(), "CREATE TRIGGER `foo` BEFORE INSERT ON `planet` FOR EACH ROW PRECEDES `other` BEGIN \(bodyText()) END;")
    }

    func testSqliteTriggerCreates() throws {
        var dialect = GenericDialect()
        dialect.setTriggerSyntax(create: [.supportsBody, .supportsCondition])
        db._dialect = dialect

        try db.create(trigger: "foo", table: "planet", when: .before, event: .insert)
            .body(self.body.map { SQLRaw($0) })
            .condition("\(ident: "foo") = \(ident: "bar")" as SQLQueryString)
            .run().wait()
        XCTAssertEqual(db.results.popLast(), "CREATE TRIGGER `foo` BEFORE INSERT ON `planet` WHEN `foo` = `bar` BEGIN \(bodyText()) END;")
    }

    func testPostgreSqlTriggerCreates() throws {
        var dialect = GenericDialect()
        dialect.setTriggerSyntax(create: [.supportsForEach, .postgreSQLChecks, .supportsCondition, .conditionRequiresParentheses, .supportsConstraints])

        db._dialect = dialect

        try db.create(trigger: "foo", table: "planet", when: .after, event: .insert)
            .each(.row)
            .isConstraint()
            .timing(.initiallyDeferred)
            .condition("\(ident: "foo") = \(ident: "bar")" as SQLQueryString)
            .procedure("qwer")
            .referencedTable(SQLIdentifier("galaxies"))
            .run().wait()

        XCTAssertEqual(db.results.popLast(), "CREATE CONSTRAINT TRIGGER `foo` AFTER INSERT ON `planet` FROM `galaxies` INITIALLY DEFERRED FOR EACH ROW WHEN (`foo` = `bar`) EXECUTE PROCEDURE `qwer`")
    }
}
