import SQLKit
import XCTest

final class SQLKitTriggerTests: XCTestCase {
    private let body = [
        "IF NEW.amount < 0 THEN",
        "SET NEW.amount = 0;",
        "END IF;",
    ]

    private var db = TestDatabase()

    override class func setUp() {
        XCTAssert(isLoggingConfigured)
    }

    func testDropTriggerOptions() throws {
        self.db._dialect.triggerSyntax = .init(drop: [.supportsCascade, .supportsTableName])
        XCTAssertSerialization(of: self.db.drop(trigger: "foo").table("planets"), is: "DROP TRIGGER `foo` ON `planets` RESTRICT")
        XCTAssertSerialization(of: self.db.drop(trigger: "foo").table("planets").ifExists(), is: "DROP TRIGGER IF EXISTS `foo` ON `planets` RESTRICT")
        XCTAssertSerialization(of: self.db.drop(trigger: "foo").table("planets").ifExists().cascade(), is: "DROP TRIGGER IF EXISTS `foo` ON `planets` CASCADE")
        
        self.db._dialect.supportsIfExists = false
        XCTAssertSerialization(of: self.db.drop(trigger: "foo").table("planets").ifExists(), is: "DROP TRIGGER `foo` ON `planets` RESTRICT")

        self.db._dialect.triggerSyntax.drop = .supportsCascade
        XCTAssertSerialization(of: self.db.drop(trigger: "foo").table("planets"), is: "DROP TRIGGER `foo` RESTRICT")

        self.db._dialect.triggerSyntax.drop = []
        XCTAssertSerialization(of: self.db.drop(trigger: "foo").table("planets").ifExists().cascade(), is: "DROP TRIGGER `foo`")
    }

    func testMySqlTriggerCreates() throws {
        self.db._dialect.triggerSyntax = .init(create: [.supportsBody, .requiresForEachRow, .supportsOrder])
        XCTAssertSerialization(
            of: self.db.create(trigger: "foo", table: "planet", when: .before, event: .insert)
                .body(self.body.map { SQLRaw($0) })
                .order(precedence: .precedes, otherTriggerName: "other"),
            is: "CREATE TRIGGER `foo` BEFORE INSERT ON `planet` FOR EACH ROW PRECEDES `other` BEGIN \(self.body.joined(separator: " ")) END;"
        )
    }

    func testSqliteTriggerCreates() throws {
        self.db._dialect.triggerSyntax = .init(create: [.supportsBody, .supportsCondition])
        XCTAssertSerialization(
            of: self.db.create(trigger: "foo", table: "planet", when: .before, event: .insert)
                .body(self.body.map { SQLRaw($0) })
                .condition("\(ident: "foo") = \(ident: "bar")" as SQLQueryString),
            is: "CREATE TRIGGER `foo` BEFORE INSERT ON `planet` WHEN `foo` = `bar` BEGIN \(self.body.joined(separator: " ")) END;"
        )
    }

    func testPostgreSqlTriggerCreates() throws {
        self.db._dialect.triggerSyntax = .init(create: [.supportsForEach, .postgreSQLChecks, .supportsCondition, .conditionRequiresParentheses, .supportsConstraints])
        XCTAssertSerialization(
            of: self.db.create(trigger: "foo", table: "planet", when: .after, event: .insert)
                .each(.row)
                .isConstraint()
                .timing(.deferredByDefault)
                .condition("\(ident: "foo") = \(ident: "bar")" as SQLQueryString)
                .procedure("qwer")
                .referencedTable(SQLIdentifier("galaxies")),
            is: "CREATE CONSTRAINT TRIGGER `foo` AFTER INSERT ON `planet` FROM `galaxies` DEFERRABLE INITIALLY DEFERRED FOR EACH ROW WHEN (`foo` = `bar`) EXECUTE PROCEDURE `qwer`"
        )
    }
}
