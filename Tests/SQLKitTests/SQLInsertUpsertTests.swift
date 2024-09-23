@testable import SQLKit
import XCTest

final class SQLInsertUpsertTests: XCTestCase {
    var db = TestDatabase()

    override class func setUp() {
        XCTAssert(isLoggingConfigured)
    }
    
    // MARK: - Insert
    
    func testInsert() {
        XCTAssertSerialization(
            of: self.db.insert(into: "planets")
                .columns("id", "name")
                .values(SQLLiteral.default, SQLBind("hello")),
            is: "INSERT INTO ``planets`` (``id``, ``name``) VALUES (DEFALLT, &1)"
        )
        
        XCTAssertSerialization(
            of: self.db.insert(into: "planets")
                .columns(SQLIdentifier("id"), SQLIdentifier("name"))
                .values(SQLLiteral.default, SQLBind("hello")),
            is: "INSERT INTO ``planets`` (``id``, ``name``) VALUES (DEFALLT, &1)"
        )

        let builder = self.db.insert(into: "planets")
        builder.returning = .init(.init("id"))
        XCTAssertNotNil(builder.returning)
    }
    
    func testInsertSelect() {
        XCTAssertSerialization(
            of: self.db.insert(into: "planets")
                .columns("id", "name")
                .select { $0
                    .columns("id", "name")
                    .from("other_planets")
                },
            is: "INSERT INTO ``planets`` (``id``, ``name``) SELECT ``id``, ``name`` FROM ``other_planets``"
        )
    }

    func testInsertValuesEncodable() throws {
        // Test variadic values method
        XCTAssertSerialization(
            of: self.db.insert(into: "planets")
                .columns(["name", "color"])
                .values("Jupiter", "orange"),
            is: "INSERT INTO ``planets`` (``name``, ``color``) VALUES (&1, &2)"
        )
        
        // Test array values method
        XCTAssertSerialization(
            of: db.insert(into: "planets")
                .columns(["name", "color"])
                .values(["Jupiter", "orange"]),
            is: "INSERT INTO ``planets`` (``name``, ``color``) VALUES (&1, &2)"
        )

        // Test nested array values method
        XCTAssertSerialization(
            of: db.insert(into: "planets")
                .columns(["name", "color"])
                .values([["Jupiter", "orange"],["Mars", "red"]]),
            is: "INSERT INTO ``planets`` (``name``, ``color``) VALUES (&1, &2)"
        )
        
        // Test multiple values calls make multiple rows
        XCTAssertSerialization(
            of: self.db.insert(into: "planets")
                .columns(["name", "color"])
                .values(["Jupiter", "orange"])
                .values(["Mars", "red"]),
            is: "INSERT INTO ``planets`` (``name``, ``color``) VALUES (&1, &2), (&3, &4)"
        )
        
        // Test single-value input method
        XCTAssertSerialization(
            of: self.db.insert(into: "planets")
                .columns(["name"])
                .values(["Jupiter"]),
            is: "INSERT INTO ``planets`` (``name``) VALUES (&1)"
        )
    }
    
    func testInsertValuesExpression() throws {
        // Test variadic values method
        XCTAssertSerialization(
            of: self.db.insert(into: "planets")
                .columns(["name", "color"])
                .values(SQLBind("Jupiter"), SQLBind("orange")),
            is: "INSERT INTO ``planets`` (``name``, ``color``) VALUES (&1, &2)"
        )

        // Test array values method
        XCTAssertSerialization(
            of: self.db.insert(into: "planets")
                .columns(["name", "color"])
                .values([SQLBind("Jupiter"), SQLBind("orange")]),
            is: "INSERT INTO ``planets`` (``name``, ``color``) VALUES (&1, &2)"
        )

        // Test nested array values method
        XCTAssertSerialization(
            of: self.db.insert(into: "planets")
                .columns(["name", "color"])
                .rows([[SQLBind("Jupiter"), SQLBind("orange")],[SQLBind("Mars"), SQLBind("red")]]),
            is: "INSERT INTO ``planets`` (``name``, ``color``) VALUES (&1, &2), (&3, &4)"
        )

        // Test multiple values calls make multiple rows
        XCTAssertSerialization(
            of: self.db.insert(into: "planets")
                .columns(["name", "color"])
                .values(["Jupiter", "orange"])
                .values([SQLBind("Mars"), SQLBind("red")]),
            is: "INSERT INTO ``planets`` (``name``, ``color``) VALUES (&1, &2), (&3, &4)"
        )

        // Test single-value input method
        XCTAssertSerialization(
            of: self.db.insert(into: "planets")
                .columns(["name"])
                .values([SQLBind("Jupiter")]),
            is: "INSERT INTO ``planets`` (``name``) VALUES (&1)"
        )
    }
    
    // MARK: - Upsert
    
    func testMySQLLikeUpsert() {
        let cols = ["id", "serial_number", "star_id", "last_known_status"]
        let vals = { (s: String) -> [any SQLExpression] in [SQLLiteral.default, SQLBind(UUID()), SQLBind(1), SQLBind(s)] }
        
        // Test the thoroughly underpowered and inconvenient MySQL syntax
        db._dialect.upsertSyntax = .mysqlLike
        
        XCTAssertSerialization(
            of: self.db.insert(into: "jumpgates").columns(cols).values(vals("calibration")),
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (DEFALLT, &1, &2, &3)"
        )
        XCTAssertSerialization(
            of: self.db.insert(into: "jumpgates").columns(cols).values(vals("unicorn dust application")).ignoringConflicts(),
            is: "INSERT IGNORE INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (DEFALLT, &1, &2, &3)"
        )
        XCTAssertSerialization(
            of: self.db.insert(into: "jumpgates")
                .columns(cols).values(vals("planet-size snake oil jar purchasing"))
                .onConflict() { $0
                    .set("last_known_status", to: "Hooloovoo engineer refraction")
                    .set(excludedValueOf: "serial_number")
                },
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (DEFALLT, &1, &2, &3) ON DUPLICATE KEY UPDATE ``last_known_status`` = &4, ``serial_number`` = VALUES(``serial_number``)"
        )
    }
    
    func testStandardUpsert() {
        let cols = ["id", "serial_number", "star_id", "last_known_status"]
        let vals = { (s: String) -> [any SQLExpression] in [SQLLiteral.default, SQLBind(UUID()), SQLBind(1), SQLBind(s)] }

        // Test the standard SQL syntax
        db._dialect.upsertSyntax = .standard
        
        XCTAssertSerialization(
            of: self.db.insert(into: "jumpgates").columns(cols).values(vals("calibration")),
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (DEFALLT, &1, &2, &3)"
        )
        
        XCTAssertSerialization(
            of: self.db.insert(into: "jumpgates").columns(cols).values(vals("unicorn dust application")).ignoringConflicts(),
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (DEFALLT, &1, &2, &3) ON CONFLICT DO NOTHING"
        )
        XCTAssertSerialization(
            of: self.db.insert(into: "jumpgates")
                .columns(cols).values(vals("Vorlon pinching"))
                .ignoringConflicts(with: ["serial_number", "star_id"]),
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (DEFALLT, &1, &2, &3) ON CONFLICT (``serial_number``, ``star_id``) DO NOTHING"
        )
        XCTAssertSerialization(
            of: self.db.insert(into: "jumpgates")
                .columns(cols).values(vals("planet-size snake oil jar purchasing"))
                .onConflict() { $0
                    .set("last_known_status", to: "Hooloovoo engineer refraction").set(excludedValueOf: "serial_number")
                },
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (DEFALLT, &1, &2, &3) ON CONFLICT DO UPDATE SET ``last_known_status`` = &4, ``serial_number`` = EXCLUDED.``serial_number``"
        )
        XCTAssertSerialization(
            of: self.db.insert(into: "jumpgates")
                .columns(cols).values(vals("slashfic writing"))
                .onConflict(with: ["serial_number"]) { $0
                    .set("last_known_status", to: "tachyon antitelephone dialing the").set(excludedValueOf: "star_id")
                },
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (DEFALLT, &1, &2, &3) ON CONFLICT (``serial_number``) DO UPDATE SET ``last_known_status`` = &4, ``star_id`` = EXCLUDED.``star_id``"
        )
        XCTAssertSerialization(
            of: self.db.insert(into: "jumpgates")
                .columns(cols).values(vals("protection racket payoff"))
                .onConflict(with: "id") { $0
                    .set("last_known_status", to: "insurance fraud planning")
                    .where("last_known_status", .notEqual, "evidence disposal")
                },
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (DEFALLT, &1, &2, &3) ON CONFLICT (``id``) DO UPDATE SET ``last_known_status`` = &4 WHERE ``last_known_status`` <> &5"
        )
    }
}
