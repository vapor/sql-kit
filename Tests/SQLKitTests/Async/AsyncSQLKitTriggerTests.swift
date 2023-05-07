import SQLKit
import SQLKitBenchmark
import XCTest

final class AsyncSQLKitTriggerTests: XCTestCase {
    private let body = [
        "IF NEW.amount < 0 THEN",
        "SET NEW.amount = 0;",
        "END IF;",
    ]

    private var db: TestDatabase!

    override func setUp() async throws {
        try await super.setUp()
        self.db = TestDatabase()
    }

    private func bodyText() -> String {
        body.joined(separator: " ")
    }

    func testDropTriggerOptions() async throws {
        var dialect = GenericDialect()
        dialect.setTriggerSyntax(drop: [.supportsCascade, .supportsTableName])
        debugPrint(dialect.triggerSyntax.drop)
        db._dialect = dialect

        try await db.drop(trigger: "foo").table("planets").run()
        XCTAssertEqual(db.results.popLast(), "DROP TRIGGER `foo` ON `planets`")

        try await db.drop(trigger: "foo").table("planets").ifExists().run()
        XCTAssertEqual(db.results.popLast(), "DROP TRIGGER IF EXISTS `foo` ON `planets`")

        try await db.drop(trigger: "foo").table("planets").ifExists().cascade().run()
        XCTAssertEqual(db.results.popLast(), "DROP TRIGGER IF EXISTS `foo` ON `planets` CASCADE")

        db._dialect.supportsIfExists = false
        try await db.drop(trigger: "foo").table("planets").ifExists().run()
        XCTAssertEqual(db.results.popLast(), "DROP TRIGGER `foo` ON `planets`")

        db._dialect.triggerSyntax.drop = .supportsCascade
        try await db.drop(trigger: "foo").table("planets").run()
        XCTAssertEqual(db.results.popLast(), "DROP TRIGGER `foo`")

        db._dialect.triggerSyntax.drop = []
        try await db.drop(trigger: "foo").table("planets").ifExists().cascade().run()
        XCTAssertEqual(db.results.popLast(), "DROP TRIGGER `foo`")
    }

    func testMySqlTriggerCreates() async throws {
        var dialect = GenericDialect()
        dialect.setTriggerSyntax(create: [.supportsBody, .requiresForEachRow, .supportsOrder])

        db._dialect = dialect

        try await db.create(trigger: "foo", table: "planet", when: .before, event: .insert)
            .body(self.body.map { SQLRaw($0) })
            .order(precedence: .precedes, otherTriggerName: "other")
            .run()
        XCTAssertEqual(db.results.popLast(), "CREATE TRIGGER `foo` BEFORE INSERT ON `planet` FOR EACH ROW PRECEDES `other` BEGIN \(bodyText()) END;")
    }

    func testSqliteTriggerCreates() async throws {
        var dialect = GenericDialect()
        dialect.setTriggerSyntax(create: [.supportsBody, .supportsCondition])
        db._dialect = dialect

        try await db.create(trigger: "foo", table: "planet", when: .before, event: .insert)
            .body(self.body.map { SQLRaw($0) })
            .condition("\(ident: "foo") = \(ident: "bar")" as SQLQueryString)
            .run()
        XCTAssertEqual(db.results.popLast(), "CREATE TRIGGER `foo` BEFORE INSERT ON `planet` WHEN `foo` = `bar` BEGIN \(bodyText()) END;")
    }

    func testPostgreSqlTriggerCreates() async throws {
        var dialect = GenericDialect()
        dialect.setTriggerSyntax(create: [.supportsForEach, .postgreSQLChecks, .supportsCondition, .conditionRequiresParentheses, .supportsConstraints])

        db._dialect = dialect

        try await db.create(trigger: "foo", table: "planet", when: .after, event: .insert)
            .each(.row)
            .isConstraint()
            .timing(.initiallyDeferred)
            .condition("\(ident: "foo") = \(ident: "bar")" as SQLQueryString)
            .procedure("qwer")
            .referencedTable(SQLIdentifier("galaxies"))
            .run()

        XCTAssertEqual(db.results.popLast(), "CREATE CONSTRAINT TRIGGER `foo` AFTER INSERT ON `planet` FROM `galaxies` INITIALLY DEFERRED FOR EACH ROW WHEN (`foo` = `bar`) EXECUTE PROCEDURE `qwer`")
    }
}
