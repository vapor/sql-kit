import SQLKit
import XCTest

final class SQLKitTriggerTests: XCTestCase {
    private let body = [
        "IF NEW.amount < 0 THEN",
        "SET NEW.amount = 0;",
        "END IF;",
    ]

    private var db: TestDatabase!

    override class func setUp() {
        XCTAssert(isLoggingConfigured)
    }
    
    override func setUp() {
        super.setUp()
        self.db = TestDatabase()
    }

    func testDropTriggerOptions() throws {
        self.db._dialect.setTriggerSyntax(drop: [.supportsCascade, .supportsTableName])
        XCTAssertEqual(
            try self.db.drop(trigger: "foo").table("planets").simpleSerialize(),
            "DROP TRIGGER `foo` ON `planets`"
        )
        XCTAssertEqual(
            try self.db.drop(trigger: "foo").table("planets").ifExists().simpleSerialize(),
            "DROP TRIGGER IF EXISTS `foo` ON `planets`"
        )
        XCTAssertEqual(
            try self.db.drop(trigger: "foo").table("planets").ifExists().cascade().simpleSerialize(),
            "DROP TRIGGER IF EXISTS `foo` ON `planets` CASCADE"
        )
        
        self.db._dialect.supportsIfExists = false
        XCTAssertEqual(
            try self.db.drop(trigger: "foo").table("planets").ifExists().simpleSerialize(),
            "DROP TRIGGER `foo` ON `planets`"
        )

        self.db._dialect.triggerSyntax.drop = .supportsCascade
        XCTAssertEqual(
            try self.db.drop(trigger: "foo").table("planets").simpleSerialize(),
            "DROP TRIGGER `foo`"
        )

        self.db._dialect.triggerSyntax.drop = []
        XCTAssertEqual(
            try self.db.drop(trigger: "foo").table("planets").ifExists().cascade().simpleSerialize(),
            "DROP TRIGGER `foo`"
        )
    }

    func testMySqlTriggerCreates() throws {
        self.db._dialect.setTriggerSyntax(create: [.supportsBody, .requiresForEachRow, .supportsOrder])
        XCTAssertEqual(try self.db
            .create(trigger: "foo", table: "planet", when: .before, event: .insert)
            .body(self.body.map { SQLRaw($0) })
            .order(precedence: .precedes, otherTriggerName: "other")
            .simpleSerialize(),
            "CREATE TRIGGER `foo` BEFORE INSERT ON `planet` FOR EACH ROW PRECEDES `other` BEGIN \(self.body.joined(separator: " ")) END;"
        )
    }

    func testSqliteTriggerCreates() throws {
        self.db._dialect.setTriggerSyntax(create: [.supportsBody, .supportsCondition])
        XCTAssertEqual(try self.db
            .create(trigger: "foo", table: "planet", when: .before, event: .insert)
            .body(self.body.map { SQLRaw($0) })
            .condition("\(ident: "foo") = \(ident: "bar")" as SQLQueryString)
            .simpleSerialize(),
            "CREATE TRIGGER `foo` BEFORE INSERT ON `planet` WHEN `foo` = `bar` BEGIN \(self.body.joined(separator: " ")) END;"
        )
    }

    func testPostgreSqlTriggerCreates() throws {
        self.db._dialect.setTriggerSyntax(create: [.supportsForEach, .postgreSQLChecks, .supportsCondition, .conditionRequiresParentheses, .supportsConstraints])
        XCTAssertEqual(try self.db
            .create(trigger: "foo", table: "planet", when: .after, event: .insert)
            .each(.row)
            .isConstraint()
            .timing(.initiallyDeferred)
            .condition("\(ident: "foo") = \(ident: "bar")" as SQLQueryString)
            .procedure("qwer")
            .referencedTable(SQLIdentifier("galaxies"))
            .simpleSerialize(),
            "CREATE CONSTRAINT TRIGGER `foo` AFTER INSERT ON `planet` FROM `galaxies` INITIALLY DEFERRED FOR EACH ROW WHEN (`foo` = `bar`) EXECUTE PROCEDURE `qwer`"
        )
    }
}
