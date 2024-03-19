import SQLKit
import XCTest

final class SQLCreateDropTriggerTests: XCTestCase {
    private let body = [
        "IF NEW.amount < 0 THEN",
        "SET NEW.amount = 0;",
        "END IF;",
    ]

    private var db = TestDatabase()

    override class func setUp() {
        XCTAssert(isLoggingConfigured)
    }

    func testDropTriggerOptions() {
        self.db._dialect.triggerSyntax = .init(drop: [.supportsCascade, .supportsTableName])
        XCTAssertSerialization(of: self.db.drop(trigger: "foo").table("planets"), is: "DROP TRIGGER ``foo`` ON ``planets`` RESTRICT")
        XCTAssertSerialization(of: self.db.drop(trigger: "foo").table("planets").ifExists(), is: "DROP TRIGGER IF EXISTS ``foo`` ON ``planets`` RESTRICT")
        XCTAssertSerialization(of: self.db.drop(trigger: "foo").table("planets").ifExists().restrict(), is: "DROP TRIGGER IF EXISTS ``foo`` ON ``planets`` RESTRICT")
        XCTAssertSerialization(of: self.db.drop(trigger: "foo").table("planets").ifExists().cascade(), is: "DROP TRIGGER IF EXISTS ``foo`` ON ``planets`` CASCADE")
        
        self.db._dialect.supportsIfExists = false
        XCTAssertSerialization(of: self.db.drop(trigger: "foo").table("planets").ifExists(), is: "DROP TRIGGER ``foo`` ON ``planets`` RESTRICT")

        self.db._dialect.triggerSyntax.drop = .supportsCascade
        XCTAssertSerialization(of: self.db.drop(trigger: "foo").table("planets"), is: "DROP TRIGGER ``foo`` RESTRICT")

        self.db._dialect.triggerSyntax.drop = []
        XCTAssertSerialization(of: self.db.drop(trigger: "foo").table("planets").ifExists().restrict(), is: "DROP TRIGGER ``foo``")
        XCTAssertSerialization(of: self.db.drop(trigger: "foo").table("planets").ifExists().cascade(), is: "DROP TRIGGER ``foo``")
    }

    func testMySqlTriggerCreates() {
        self.db._dialect.triggerSyntax = .init(create: [.supportsBody, .supportsOrder, .supportsDefiner, .requiresForEachRow])

        let builder = self.db.create(trigger: "foo", table: "planet", when: .before, event: .insert)
                .body(self.body.map { SQLRaw($0) })
                .order(precedence: .precedes, otherTriggerName: "other")
        builder.createTrigger.definer = SQLLiteral.string("foo@bar")
        
        XCTAssertSerialization(
            of: builder,
            is: "CREATE DEFINER = 'foo@bar' TRIGGER ``foo`` BEFORE INSERT ON ``planet`` FOR EACH ROW PRECEDES ``other`` BEGIN \(self.body.joined(separator: " ")) END;"
        )
    }

    func testSqliteTriggerCreates() {
        self.db._dialect.triggerSyntax = .init(create: [.supportsBody, .supportsCondition])
        XCTAssertSerialization(
            of: self.db.create(trigger: "foo", table: "planet", when: .before, event: .insert)
                .body(self.body.map { SQLRaw($0) })
                .condition("\(ident: "foo") = \(ident: "bar")" as SQLQueryString),
            is: "CREATE TRIGGER ``foo`` BEFORE INSERT ON ``planet`` WHEN ``foo`` = ``bar`` BEGIN \(self.body.joined(separator: " ")) END;"
        )
    }

    func testPostgreSqlTriggerCreates() {
        self.db._dialect.triggerSyntax = .init(create: [.supportsForEach, .postgreSQLChecks, .supportsCondition, .conditionRequiresParentheses, .supportsConstraints])
        XCTAssertSerialization(
            of: self.db.create(trigger: "foo", table: "planet", when: .after, event: .insert)
                .each(.row)
                .isConstraint()
                .timing(.deferredByDefault)
                .condition("\(ident: "foo") = \(ident: "bar")" as SQLQueryString)
                .procedure("qwer")
                .referencedTable("galaxies"),
            is: "CREATE CONSTRAINT TRIGGER ``foo`` AFTER INSERT ON ``planet`` FROM ``galaxies`` DEFERRABLE INITIALLY DEFERRED FOR EACH ROW WHEN (``foo`` = ``bar``) EXECUTE PROCEDURE ``qwer``"
        )
    }
    
    func testPostgreSqlTriggerCreateWithColumns() {
        self.db._dialect.triggerSyntax = .init(create: [.supportsForEach, .postgreSQLChecks, .supportsCondition, .conditionRequiresParentheses, .supportsConstraints, .supportsUpdateColumns])
        XCTAssertSerialization(
            of: self.db.create(trigger: "foo", table: "planet", when: .after, event: .update)
                .each(.row)
                .columns(["foo"])
                .condition("\(ident: "foo") = \(ident: "bar")" as SQLQueryString)
                .procedure("qwer")
                .referencedTable("galaxies"),
            is: "CREATE TRIGGER ``foo`` AFTER UPDATE OF ``foo`` ON ``planet`` FROM ``galaxies`` FOR EACH ROW WHEN (``foo`` = ``bar``) EXECUTE PROCEDURE ``qwer``"
        )
    }
    
    func testAdditionalInitializer() {
        self.db._dialect.triggerSyntax = .init(create: [.supportsBody, .supportsCondition])
        var query = SQLCreateTrigger(trigger: "t", table: "tab", when: .after, event: .delete)
        query.body = self.body.map { SQLRaw($0) }

        XCTAssertSerialization(of: self.db.raw("\(query)"), is: "CREATE TRIGGER ``t`` AFTER DELETE ON ``tab`` BEGIN IF NEW.amount < 0 THEN SET NEW.amount = 0; END IF; END;")
    }
}
