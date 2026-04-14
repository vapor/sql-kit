#if canImport(FoundationEssentials)
import struct FoundationEssentials.UUID
#else
import struct Foundation.UUID
#endif
@testable import SQLKit
import Testing

@Suite("UPSERT tests")
struct InsertUpsertTests {
    // MARK: - Insert

    @Test("INSERT")
    func insert() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.insert(into: "planets")
                .columns("id", "name")
                .values(SQLLiteral.default, SQLBind("hello")),
            is: "INSERT INTO ``planets`` (``id``, ``name``) VALUES (DEFALLT, &1)"
        )

        try expectSerialization(
            of: db.insert(into: "planets")
                .columns(SQLIdentifier("id"), SQLIdentifier("name"))
                .values(SQLLiteral.default, SQLBind("hello")),
            is: "INSERT INTO ``planets`` (``id``, ``name``) VALUES (DEFALLT, &1)"
        )

        let builder = db.insert(into: "planets")
        builder.returning = .init(.init("id"))
        #expect(builder.returning != nil)
    }

    @Test("INSERT ... SELECT")
    func insertSelect() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.insert(into: "planets")
                .columns("id", "name")
                .select { $0
                    .columns("id", "name")
                    .from("other_planets")
                },
            is: "INSERT INTO ``planets`` (``id``, ``name``) SELECT ``id``, ``name`` FROM ``other_planets``"
        )
    }

    @Test("INSERT ... VALUES (Encodable)")
    func insertValuesEncodable() throws {
        let db = TestDatabase()

        // Test variadic values method
        try expectSerialization(
            of: db.insert(into: "planets")
                .columns(["name", "color"])
                .values("Jupiter", "orange"),
            is: "INSERT INTO ``planets`` (``name``, ``color``) VALUES (&1, &2)"
        )

        // Test array values method
        try expectSerialization(
            of: db.insert(into: "planets")
                .columns(["name", "color"])
                .values(["Jupiter", "orange"]),
            is: "INSERT INTO ``planets`` (``name``, ``color``) VALUES (&1, &2)"
        )

        // Test nested array values method
        try expectSerialization(
            of: db.insert(into: "planets")
                .columns(["name", "color"])
                .values([["Jupiter", "orange"],["Mars", "red"]]),
            is: "INSERT INTO ``planets`` (``name``, ``color``) VALUES (&1, &2)"
        )

        // Test multiple values calls make multiple rows
        try expectSerialization(
            of: db.insert(into: "planets")
                .columns(["name", "color"])
                .values(["Jupiter", "orange"])
                .values(["Mars", "red"]),
            is: "INSERT INTO ``planets`` (``name``, ``color``) VALUES (&1, &2), (&3, &4)"
        )

        // Test single-value input method
        try expectSerialization(
            of: db.insert(into: "planets")
                .columns(["name"])
                .values(["Jupiter"]),
            is: "INSERT INTO ``planets`` (``name``) VALUES (&1)"
        )
    }

    @Test("INSERT ... VALUES (Expression)")
    func insertValuesExpression() throws {
        let db = TestDatabase()

        // Test variadic values method
        try expectSerialization(
            of: db.insert(into: "planets")
                .columns(["name", "color"])
                .values(SQLBind("Jupiter"), SQLBind("orange")),
            is: "INSERT INTO ``planets`` (``name``, ``color``) VALUES (&1, &2)"
        )

        // Test array values method
        try expectSerialization(
            of: db.insert(into: "planets")
                .columns(["name", "color"])
                .values([SQLBind("Jupiter"), SQLBind("orange")]),
            is: "INSERT INTO ``planets`` (``name``, ``color``) VALUES (&1, &2)"
        )

        // Test nested array values method
        try expectSerialization(
            of: db.insert(into: "planets")
                .columns(["name", "color"])
                .rows([[SQLBind("Jupiter"), SQLBind("orange")],[SQLBind("Mars"), SQLBind("red")]]),
            is: "INSERT INTO ``planets`` (``name``, ``color``) VALUES (&1, &2), (&3, &4)"
        )

        // Test multiple values calls make multiple rows
        try expectSerialization(
            of: db.insert(into: "planets")
                .columns(["name", "color"])
                .values(["Jupiter", "orange"])
                .values([SQLBind("Mars"), SQLBind("red")]),
            is: "INSERT INTO ``planets`` (``name``, ``color``) VALUES (&1, &2), (&3, &4)"
        )

        // Test single-value input method
        try expectSerialization(
            of: db.insert(into: "planets")
                .columns(["name"])
                .values([SQLBind("Jupiter")]),
            is: "INSERT INTO ``planets`` (``name``) VALUES (&1)"
        )
    }

    // MARK: - Upsert

    @Test("MySQL-like UPSERT")
    func mySQLLikeUpsert() throws {
        let db = TestDatabase()
        let cols = ["id", "serial_number", "star_id", "last_known_status"]
        let vals = { (s: String) -> [any SQLExpression] in [SQLLiteral.default, SQLBind(UUID()), SQLBind(1), SQLBind(s)] }

        // Test the thoroughly underpowered and inconvenient MySQL syntax
        db._dialect.upsertSyntax = .mysqlLike

        try expectSerialization(
            of: db.insert(into: "jumpgates").columns(cols).values(vals("calibration")),
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (DEFALLT, &1, &2, &3)"
        )
        try expectSerialization(
            of: db.insert(into: "jumpgates").columns(cols).values(vals("unicorn dust application")).ignoringConflicts(),
            is: "INSERT IGNORE INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (DEFALLT, &1, &2, &3)"
        )
        try expectSerialization(
            of: db.insert(into: "jumpgates")
                .columns(cols).values(vals("planet-size snake oil jar purchasing"))
                .onConflict() { $0
                    .set("last_known_status", to: "Hooloovoo engineer refraction")
                    .set(excludedValueOf: "serial_number")
                },
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (DEFALLT, &1, &2, &3) ON DUPLICATE KEY UPDATE ``last_known_status`` = &4, ``serial_number`` = VALUES(``serial_number``)"
        )
    }

    @Test("standard UPSERT")
    func standardUpsert() throws {
        let db = TestDatabase()
        let cols = ["id", "serial_number", "star_id", "last_known_status"]
        let vals = { (s: String) -> [any SQLExpression] in [SQLLiteral.default, SQLBind(UUID()), SQLBind(1), SQLBind(s)] }

        // Test the standard SQL syntax
        db._dialect.upsertSyntax = .standard

        try expectSerialization(
            of: db.insert(into: "jumpgates").columns(cols).values(vals("calibration")),
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (DEFALLT, &1, &2, &3)"
        )

        try expectSerialization(
            of: db.insert(into: "jumpgates").columns(cols).values(vals("unicorn dust application")).ignoringConflicts(),
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (DEFALLT, &1, &2, &3) ON CONFLICT DO NOTHING"
        )
        try expectSerialization(
            of: db.insert(into: "jumpgates")
                .columns(cols).values(vals("Vorlon pinching"))
                .ignoringConflicts(with: ["serial_number", "star_id"]),
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (DEFALLT, &1, &2, &3) ON CONFLICT (``serial_number``, ``star_id``) DO NOTHING"
        )
        try expectSerialization(
            of: db.insert(into: "jumpgates")
                .columns(cols).values(vals("planet-size snake oil jar purchasing"))
                .onConflict() { $0
                    .set("last_known_status", to: "Hooloovoo engineer refraction").set(excludedValueOf: "serial_number")
                },
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (DEFALLT, &1, &2, &3) ON CONFLICT DO UPDATE SET ``last_known_status`` = &4, ``serial_number`` = EXCLUDED.``serial_number``"
        )
        try expectSerialization(
            of: db.insert(into: "jumpgates")
                .columns(cols).values(vals("slashfic writing"))
                .onConflict(with: ["serial_number"]) { $0
                    .set("last_known_status", to: "tachyon antitelephone dialing the").set(excludedValueOf: "star_id")
                },
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (DEFALLT, &1, &2, &3) ON CONFLICT (``serial_number``) DO UPDATE SET ``last_known_status`` = &4, ``star_id`` = EXCLUDED.``star_id``"
        )
        try expectSerialization(
            of: db.insert(into: "jumpgates")
                .columns(cols).values(vals("protection racket payoff"))
                .onConflict(with: "id") { $0
                    .set("last_known_status", to: "insurance fraud planning")
                    .where("last_known_status", .notEqual, "evidence disposal")
                },
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (DEFALLT, &1, &2, &3) ON CONFLICT (``id``) DO UPDATE SET ``last_known_status`` = &4 WHERE ``last_known_status`` <> &5"
        )
    }

    @Test("generic/nonstandard UPSERT")
    func genericNonstandardUpsert() throws {
        let db = TestDatabase()
        let cols = ["id", "serial_number", "star_id", "last_known_status"]
        let vals = { (s: String) -> [any SQLExpression] in [SQLLiteral.default, SQLBind(UUID()), SQLBind(1), SQLBind(s)] }

        db._dialect.upsertSyntax = .standard

        try expectSerialization(
            of: db.insert(into: "jumpgates")
                .columns(cols).values(vals("Vorlon pinching"))
                .ignoringConflicts(withThing: SQLIdentifier("serial_number")),
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (DEFALLT, &1, &2, &3) ON CONFLICT ON CONSTRAINT ``serial_number`` DO NOTHING"
        )
        try expectSerialization(
            of: db.insert(into: "jumpgates")
                .columns(cols).values(vals("slashfic writing"))
                .onConflict(withThing: SQLIdentifier("serial_number")) { $0
                    .set("last_known_status", to: "tachyon antitelephone dialing the").set(excludedValueOf: "star_id")
                },
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (DEFALLT, &1, &2, &3) ON CONFLICT ON CONSTRAINT ``serial_number`` DO UPDATE SET ``last_known_status`` = &4, ``star_id`` = EXCLUDED.``star_id``"
        )
        try expectSerialization(
            of: db.insert(into: "jumpgates")
                .columns(cols).values(vals("protection racket payoff"))
                .onConflict(withThing: SQLIdentifier("id")) { $0
                    .set("last_known_status", to: "insurance fraud planning")
                    .where("last_known_status", .notEqual, "evidence disposal")
                },
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (DEFALLT, &1, &2, &3) ON CONFLICT ON CONSTRAINT ``id`` DO UPDATE SET ``last_known_status`` = &4 WHERE ``last_known_status`` <> &5"
        )
    }
}

extension SQLInsertBuilder {
    struct SQLCustomConflictResolutionStrategy: SQLExpression {
        var thing: any SQLExpression, action: SQLConflictAction
        func serialize(to serializer: inout SQLSerializer) {
            serializer.statement {
                $0.append("ON CONFLICT ON CONSTRAINT", self.thing)
                switch self.action {
                case .noAction: $0.append("DO NOTHING")
                case .update(let assignments, let predicate):
                    $0.append("DO UPDATE SET", SQLList(assignments))
                    if let predicate { $0.append("WHERE", predicate) }
                }
            }
        }
    }
    @discardableResult
    func ignoringConflicts(withThing thing: any SQLExpression) -> Self {
        self.insert.genericConflictStrategy = SQLCustomConflictResolutionStrategy(thing: thing, action: .noAction)
        return self
    }
    @discardableResult
    func onConflict(withThing thing: any SQLExpression, `do` updatePredicate: (SQLConflictUpdateBuilder) throws -> SQLConflictUpdateBuilder) rethrows -> Self {
        let conflictBuilder = SQLConflictUpdateBuilder()
        _ = try updatePredicate(conflictBuilder)
        self.insert.genericConflictStrategy = SQLCustomConflictResolutionStrategy(thing: thing, action: .update(assignments: conflictBuilder.values, predicate: conflictBuilder.predicate))
        return self
    }
}
