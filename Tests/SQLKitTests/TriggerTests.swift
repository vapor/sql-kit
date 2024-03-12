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
        self.db._dialect.supportsDropBehavior = true
        self.db._dialect.triggerSyntax = .init(drop: [.supportsCascade, .supportsTableName])
        XCTAssertEqual(
            self.db.drop(trigger: "foo").table("planets").simpleSerialize(),
            "DROP TRIGGER `foo` ON `planets` RESTRICT"
        )
        XCTAssertEqual(
            self.db.drop(trigger: "foo").table("planets").ifExists().simpleSerialize(),
            "DROP TRIGGER IF EXISTS `foo` ON `planets` RESTRICT"
        )
        XCTAssertEqual(
            self.db.drop(trigger: "foo").table("planets").ifExists().cascade().simpleSerialize(),
            "DROP TRIGGER IF EXISTS `foo` ON `planets` CASCADE"
        )
        
        self.db._dialect.supportsIfExists = false
        XCTAssertEqual(
            self.db.drop(trigger: "foo").table("planets").ifExists().simpleSerialize(),
            "DROP TRIGGER `foo` ON `planets` RESTRICT"
        )

        self.db._dialect.triggerSyntax.drop = .supportsCascade
        XCTAssertEqual(
            self.db.drop(trigger: "foo").table("planets").simpleSerialize(),
            "DROP TRIGGER `foo` RESTRICT"
        )

        self.db._dialect.triggerSyntax.drop = []
        XCTAssertEqual(
            self.db.drop(trigger: "foo").table("planets").ifExists().cascade().simpleSerialize(),
            "DROP TRIGGER `foo`"
        )
    }

    func testMySqlTriggerCreates() throws {
        self.db._dialect.triggerSyntax = .init(create: [.supportsBody, .requiresForEachRow, .supportsOrder])
        XCTAssertEqual(self.db
            .create(trigger: "foo", table: "planet", when: .before, event: .insert)
            .body(self.body.map { SQLRaw($0) })
            .order(precedence: .precedes, otherTriggerName: "other")
            .simpleSerialize(),
            "CREATE TRIGGER `foo` BEFORE INSERT ON `planet` FOR EACH ROW PRECEDES `other` BEGIN \(self.body.joined(separator: " ")) END;"
        )
    }

    func testSqliteTriggerCreates() throws {
        self.db._dialect.triggerSyntax = .init(create: [.supportsBody, .supportsCondition])
        XCTAssertEqual(self.db
            .create(trigger: "foo", table: "planet", when: .before, event: .insert)
            .body(self.body.map { SQLRaw($0) })
            .condition("\(ident: "foo") = \(ident: "bar")" as SQLQueryString)
            .simpleSerialize(),
            "CREATE TRIGGER `foo` BEFORE INSERT ON `planet` WHEN `foo` = `bar` BEGIN \(self.body.joined(separator: " ")) END;"
        )
    }

    func testPostgreSqlTriggerCreates() throws {
        self.db._dialect.triggerSyntax = .init(create: [.supportsForEach, .postgreSQLChecks, .supportsCondition, .conditionRequiresParentheses, .supportsConstraints])
        XCTAssertEqual(self.db
            .create(trigger: "foo", table: "planet", when: .after, event: .insert)
            .each(.row)
            .isConstraint()
            .timing(.deferredByDefault)
            .condition("\(ident: "foo") = \(ident: "bar")" as SQLQueryString)
            .procedure("qwer")
            .referencedTable(SQLIdentifier("galaxies"))
            .simpleSerialize(),
            "CREATE CONSTRAINT TRIGGER `foo` AFTER INSERT ON `planet` FROM `galaxies` DEFERRABLE INITIALLY DEFERRED FOR EACH ROW WHEN (`foo` = `bar`) EXECUTE PROCEDURE `qwer`"
        )
    }
}
