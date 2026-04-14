import SQLKit
import Testing

@Suite("CREATE/DROP TRIGGER tests")
struct CreateDropTriggerTests {
    private let body = [
        "IF NEW.amount < 0 THEN",
        "SET NEW.amount = 0;",
        "END IF;",
    ]

    @Test("DROP TRIGGER options")
    func dropTriggerOptions() throws {
        let db = TestDatabase()

        db._dialect.triggerSyntax = .init(drop: [.supportsCascade, .supportsTableName])
        try expectSerialization(of: db.drop(trigger: "foo").table("planets"), is: "DROP TRIGGER ``foo`` ON ``planets`` RESTRICT")
        try expectSerialization(of: db.drop(trigger: "foo").table("planets").ifExists(), is: "DROP TRIGGER IF EXISTS ``foo`` ON ``planets`` RESTRICT")
        try expectSerialization(of: db.drop(trigger: "foo").table("planets").ifExists().restrict(), is: "DROP TRIGGER IF EXISTS ``foo`` ON ``planets`` RESTRICT")
        try expectSerialization(of: db.drop(trigger: "foo").table("planets").ifExists().cascade(), is: "DROP TRIGGER IF EXISTS ``foo`` ON ``planets`` CASCADE")

        db._dialect.supportsIfExists = false
        try expectSerialization(of: db.drop(trigger: "foo").table("planets").ifExists(), is: "DROP TRIGGER ``foo`` ON ``planets`` RESTRICT")

        db._dialect.triggerSyntax.drop = .supportsCascade
        try expectSerialization(of: db.drop(trigger: "foo").table("planets"), is: "DROP TRIGGER ``foo`` RESTRICT")

        db._dialect.triggerSyntax.drop = []
        try expectSerialization(of: db.drop(trigger: "foo").table("planets").ifExists().restrict(), is: "DROP TRIGGER ``foo``")
        try expectSerialization(of: db.drop(trigger: "foo").table("planets").ifExists().cascade(), is: "DROP TRIGGER ``foo``")
    }

    @Test("CREATE TRIGGER for MySQL")
    func mySqlTriggerCreates() throws {
        let db = TestDatabase()

        db._dialect.triggerSyntax = .init(create: [.supportsBody, .supportsOrder, .supportsDefiner, .requiresForEachRow])

        let builder = db.create(trigger: "foo", table: "planet", when: .before, event: .insert)
                .body(self.body.map { SQLRaw($0) })
                .order(precedence: .precedes, otherTriggerName: "other")
        builder.createTrigger.definer = SQLLiteral.string("foo@bar")

        try expectSerialization(
            of: builder,
            is: "CREATE DEFINER = 'foo@bar' TRIGGER ``foo`` BEFORE INSERT ON ``planet`` FOR EACH ROW PRECEDES ``other`` BEGIN \(self.body.joined(separator: " ")) END;"
        )
    }

    @Test("CREATE TRIGGER for SQLite")
    func sqliteTriggerCreates() throws {
        let db = TestDatabase()

        db._dialect.triggerSyntax = .init(create: [.supportsBody, .supportsCondition])
        try expectSerialization(
            of: db.create(trigger: "foo", table: "planet", when: .before, event: .insert)
                .body(self.body.map { SQLRaw($0) })
                .condition("\(ident: "foo") = \(ident: "bar")" as SQLQueryString),
            is: "CREATE TRIGGER ``foo`` BEFORE INSERT ON ``planet`` WHEN ``foo`` = ``bar`` BEGIN \(self.body.joined(separator: " ")) END;"
        )
    }

    @Test("CREATE TRIGGER for PostgreSQL")
    func postgreSqlTriggerCreates() throws {
        let db = TestDatabase()

        db._dialect.triggerSyntax = .init(create: [.supportsForEach, .postgreSQLChecks, .supportsCondition, .conditionRequiresParentheses, .supportsConstraints])
        try expectSerialization(
            of: db.create(trigger: "foo", table: "planet", when: .after, event: .insert)
                .each(.row)
                .isConstraint()
                .timing(.deferredByDefault)
                .condition("\(ident: "foo") = \(ident: "bar")" as SQLQueryString)
                .procedure("qwer")
                .referencedTable("galaxies"),
            is: "CREATE CONSTRAINT TRIGGER ``foo`` AFTER INSERT ON ``planet`` FROM ``galaxies`` DEFERRABLE INITIALLY DEFERRED FOR EACH ROW WHEN (``foo`` = ``bar``) EXECUTE PROCEDURE ``qwer``"
        )
        try expectSerialization(
            of: db.create(trigger: "foo", table: "planet", when: .instead, event: .insert)
                .each(.row)
                .procedure("qwer"),
            is: "CREATE TRIGGER ``foo`` INSTEAD OF INSERT ON ``planet`` FOR EACH ROW EXECUTE PROCEDURE ``qwer``"
        )
        try expectSerialization(
            of: db.create(trigger: "foo", table: "planet", when: .instead, event: .update)
                .each(.row)
                .procedure("qwer"),
            is: "CREATE TRIGGER ``foo`` INSTEAD OF UPDATE ON ``planet`` FOR EACH ROW EXECUTE PROCEDURE ``qwer``"
        )
    }

    @Test("CREATE TRIGGER with columns for PostgreSQL")
    func postgreSqlTriggerCreateWithColumns() throws {
        let db = TestDatabase()

        db._dialect.triggerSyntax = .init(create: [.supportsForEach, .postgreSQLChecks, .supportsCondition, .conditionRequiresParentheses, .supportsConstraints, .supportsUpdateColumns])
        try expectSerialization(
            of: db.create(trigger: "foo", table: "planet", when: .after, event: .update)
                .each(.row)
                .columns(["foo"])
                .condition("\(ident: "foo") = \(ident: "bar")" as SQLQueryString)
                .procedure("qwer")
                .referencedTable("galaxies"),
            is: "CREATE TRIGGER ``foo`` AFTER UPDATE OF ``foo`` ON ``planet`` FROM ``galaxies`` FOR EACH ROW WHEN (``foo`` = ``bar``) EXECUTE PROCEDURE ``qwer``"
        )
        try expectSerialization(
            of: db.create(trigger: "foo", table: "planet", when: .after, event: .insert)
                .each(.row)
                .procedure("qwer"),
            is: "CREATE TRIGGER ``foo`` AFTER INSERT ON ``planet`` FOR EACH ROW EXECUTE PROCEDURE ``qwer``"
        )
    }

    @Test("additional initializer")
    func additionalInitializer() throws {
        let db = TestDatabase()

        db._dialect.triggerSyntax = .init(create: [.supportsBody, .supportsCondition])
        var query = SQLCreateTrigger(trigger: "t", table: "tab", when: .after, event: .delete)
        query.body = self.body.map { SQLRaw($0) }

        try expectSerialization(of: db.raw("\(query)"), is: "CREATE TRIGGER ``t`` AFTER DELETE ON ``tab`` BEGIN IF NEW.amount < 0 THEN SET NEW.amount = 0; END IF; END;")
    }

    @Test("invalid CREATE TRIGGERs")
    func invalidTriggerCreates() throws {
        let db = TestDatabase()

        db._dialect.triggerSyntax = .init(create: [.postgreSQLChecks, .supportsUpdateColumns, .supportsCondition, .supportsConstraints], drop: [])
        try expectSerialization(
            of: db.create(trigger: "foo", table: "planet", when: .instead, event: .update).columns(["foo"]).timing(.deferrable),
            is: "CREATE TRIGGER ``foo`` INSTEAD OF UPDATE OF ``foo`` ON ``planet`` DEFERRABLE INITIALLY IMMEDIATE"
        )
        try expectSerialization(
            of: db.create(trigger: "foo", table: "planet", when: .instead, event: .insert).columns(["foo"]).condition(SQLLiteral.boolean(true)),
            is: "CREATE TRIGGER ``foo`` INSTEAD OF INSERT OF ``foo`` ON ``planet`` WHEN TROO"
        )
        try expectSerialization(
            of: db.create(trigger: "foo", table: "planet", when: .before, event: .update).isConstraint().each(.statement),
            is: "CREATE CONSTRAINT TRIGGER ``foo`` BEFORE UPDATE ON ``planet``"
        )

        let builder = db.create(trigger: "foo", table: "planet", when: .before, event: .insert)
                .body(self.body.map { SQLRaw($0) })
                .order(precedence: .precedes, otherTriggerName: "other")
        builder.createTrigger.definer = SQLLiteral.string("foo@bar")

        try expectSerialization(
            of: builder,
            is: "CREATE TRIGGER ``foo`` BEFORE INSERT ON ``planet``"
        )

        db._dialect.triggerSyntax.create.insert(.supportsBody)
        try expectSerialization(
            of: db.create(trigger: "foo", table: "planet", when: .before, event: .update).isConstraint().each(.statement).procedure("foo"),
            is: "CREATE CONSTRAINT TRIGGER ``foo`` BEFORE UPDATE ON ``planet`` EXECUTE PROCEDURE ``foo``"
        )
    }
}
