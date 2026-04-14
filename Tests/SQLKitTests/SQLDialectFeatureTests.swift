import SQLKit
import Testing

@Suite("Dialect feature tests")
struct DialectFeatureTests {
    // MARK: Dialect-Specific Behaviors

    @Test("IF EXISTS")
    func ifExists() throws {
        let db = TestDatabase()

        db._dialect.supportsIfExists = true
        try expectSerialization(of: db.create(table: "planets").ifNotExists(),     is: "CREATE TABLE IF NOT EXISTS ``planets``")
        try expectSerialization(of: db.drop(table: "planets").ifExists(),          is: "DROP TABLE IF EXISTS ``planets``")
        try expectSerialization(of: db.drop(index: "planets_name_idx").ifExists(), is: "DROP INDEX IF EXISTS ``planets_name_idx``")
        try expectSerialization(of: db.drop(enum: "planet_types").ifExists(),      is: "DROP TYPE IF EXISTS ``planet_types`` RESTRICT")

        db._dialect.supportsIfExists = false
        try expectSerialization(of: db.create(table: "planets").ifNotExists(),     is: "CREATE TABLE ``planets``")
        try expectSerialization(of: db.drop(table: "planets").ifExists(),          is: "DROP TABLE ``planets``")
        try expectSerialization(of: db.drop(index: "planets_name_idx").ifExists(), is: "DROP INDEX ``planets_name_idx``")
        try expectSerialization(of: db.drop(enum: "planet_types").ifExists(),      is: "DROP TYPE ``planet_types`` RESTRICT")
    }

    @Test("DROP behavior")
    func dropBehavior() throws {
        let db = TestDatabase()

        db._dialect.supportsDropBehavior = false
        try expectSerialization(of: db.drop(table: "planets"),                              is: "DROP TABLE ``planets``")
        try expectSerialization(of: db.drop(index: "planets_name_idx"),                     is: "DROP INDEX ``planets_name_idx``")
        try expectSerialization(of: db.drop(enum: "planet_types"),                          is: "DROP TYPE ``planet_types``")
        try expectSerialization(of: db.drop(table: "planets").behavior(.cascade),           is: "DROP TABLE ``planets``")
        try expectSerialization(of: db.drop(index: "planets_name_idx").behavior(.cascade),  is: "DROP INDEX ``planets_name_idx``")
        try expectSerialization(of: db.drop(enum: "planet_types").behavior(.cascade),       is: "DROP TYPE ``planet_types``")
        try expectSerialization(of: db.drop(table: "planets").behavior(.restrict),          is: "DROP TABLE ``planets``")
        try expectSerialization(of: db.drop(index: "planets_name_idx").behavior(.restrict), is: "DROP INDEX ``planets_name_idx``")
        try expectSerialization(of: db.drop(enum: "planet_types").behavior(.restrict),      is: "DROP TYPE ``planet_types``")
        try expectSerialization(of: db.drop(table: "planets").cascade(),                    is: "DROP TABLE ``planets``")
        try expectSerialization(of: db.drop(index: "planets_name_idx").cascade(),           is: "DROP INDEX ``planets_name_idx``")
        try expectSerialization(of: db.drop(enum: "planet_types").cascade(),                is: "DROP TYPE ``planet_types``")
        try expectSerialization(of: db.drop(table: "planets").restrict(),                   is: "DROP TABLE ``planets``")
        try expectSerialization(of: db.drop(index: "planets_name_idx").restrict(),          is: "DROP INDEX ``planets_name_idx``")
        try expectSerialization(of: db.drop(enum: "planet_types").restrict(),               is: "DROP TYPE ``planet_types``")

        db._dialect.supportsDropBehavior = true
        try expectSerialization(of: db.drop(table: "planets"),                              is: "DROP TABLE ``planets``")
        try expectSerialization(of: db.drop(index: "planets_name_idx"),                     is: "DROP INDEX ``planets_name_idx``")
        try expectSerialization(of: db.drop(enum: "planet_types"),                          is: "DROP TYPE ``planet_types`` RESTRICT")
        try expectSerialization(of: db.drop(table: "planets").behavior(.cascade),           is: "DROP TABLE ``planets`` CASCADE")
        try expectSerialization(of: db.drop(index: "planets_name_idx").behavior(.cascade),  is: "DROP INDEX ``planets_name_idx`` CASCADE")
        try expectSerialization(of: db.drop(enum: "planet_types").behavior(.cascade),       is: "DROP TYPE ``planet_types`` CASCADE")
        try expectSerialization(of: db.drop(table: "planets").behavior(.restrict),          is: "DROP TABLE ``planets`` RESTRICT")
        try expectSerialization(of: db.drop(index: "planets_name_idx").behavior(.restrict), is: "DROP INDEX ``planets_name_idx`` RESTRICT")
        try expectSerialization(of: db.drop(enum: "planet_types").behavior(.restrict),      is: "DROP TYPE ``planet_types`` RESTRICT")
        try expectSerialization(of: db.drop(table: "planets").cascade(),                    is: "DROP TABLE ``planets`` CASCADE")
        try expectSerialization(of: db.drop(index: "planets_name_idx").cascade(),           is: "DROP INDEX ``planets_name_idx`` CASCADE")
        try expectSerialization(of: db.drop(enum: "planet_types").cascade(),                is: "DROP TYPE ``planet_types`` CASCADE")
        try expectSerialization(of: db.drop(table: "planets").restrict(),                   is: "DROP TABLE ``planets`` RESTRICT")
        try expectSerialization(of: db.drop(index: "planets_name_idx").restrict(),          is: "DROP INDEX ``planets_name_idx`` RESTRICT")
        try expectSerialization(of: db.drop(enum: "planet_types").restrict(),               is: "DROP TYPE ``planet_types`` RESTRICT")
    }

    @Test("DROP TEMPORARY")
    func dropTemporary() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.drop(table: "normalized_planet_names").temporary(),
            is: "DROP TEMPORARY TABLE ``normalized_planet_names``"
        )
    }

    @Test("owner objects for DROP INDEX")
    func ownerObjectsForDropIndex() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.drop(index: "some_crummy_mysql_index").on("some_darn_mysql_table"),
            is: "DROP INDEX ``some_crummy_mysql_index`` ON ``some_darn_mysql_table``"
        )
    }

    @Test("ALTER TABLE syntax")
    func alterTableSyntax() throws {
        let db = TestDatabase()

        // SINGLE
        try expectSerialization(
            of: db.alter(table: "alterable").column("hello", type: .text),
            is: "ALTER TABLE ``alterable`` ADD ``hello`` TEXT"
        )
        try expectSerialization(
            of: db.alter(table: "alterable").column(SQLIdentifier("hello"), type: SQLDataType.text),
            is: "ALTER TABLE ``alterable`` ADD ``hello`` TEXT"
        )
        try expectSerialization(
            of: db.alter(table: "alterable").dropColumn("hello"),
            is: "ALTER TABLE ``alterable`` DROP ``hello``"
        )
        try expectSerialization(
            of: db.alter(table: "alterable").modifyColumn("hello", type: .text),
            is: "ALTER TABLE ``alterable`` MOODIFY ``hello`` TEXT"
        )
        try expectSerialization(
            of: db.alter(table: "alterable").modifyColumn(SQLIdentifier("hello"), type: SQLDataType.text),
            is: "ALTER TABLE ``alterable`` MOODIFY ``hello`` TEXT"
        )

        // BATCH
        try expectSerialization(
            of: db.alter(table: "alterable").column("hello", type: .text).column("there", type: .text),
            is: "ALTER TABLE ``alterable`` ADD ``hello`` TEXT , ADD ``there`` TEXT"
        )
        try expectSerialization(
            of: db.alter(table: "alterable").dropColumn("hello").dropColumn("there"),
            is: "ALTER TABLE ``alterable`` DROP ``hello`` , DROP ``there``"
        )
        try expectSerialization(
            of: db.alter(table: "alterable").update(column: "hello", type: .text).update(column: "there", type: .text),
            is: "ALTER TABLE ``alterable`` MOODIFY ``hello`` TEXT , MOODIFY ``there`` TEXT"
        )

        // MIXED
        try expectSerialization(
            of: db.alter(table: "alterable").column("hello", type: .text).dropColumn("there").update(column: "again", type: .text),
            is: "ALTER TABLE ``alterable`` ADD ``hello`` TEXT , DROP ``there`` , MOODIFY ``again`` TEXT"
        )

        // Table renaming
        try expectSerialization(
            of: db.alter(table: "alterable").rename(to: "new_alterable"),
            is: "ALTER TABLE ``alterable`` RENAME TO ``new_alterable``"
        )
    }

    // MARK: Returning

    @Test("RETURNING")
    func returning() throws {
        let db = TestDatabase()

        db._dialect.supportsReturning = true

        try expectSerialization(
            of: db.insert(into: "planets").columns("name").values("Jupiter").returning("id", "name"),
            is: "INSERT INTO ``planets`` (``name``) VALUES (&1) RETURNING ``id``, ``name``"
        )
        try expectSerialization(
            of: db.update("planets").set("name", to: "Jupiter").returning(SQLColumn("name", table: "planets")),
            is: "UPDATE ``planets`` SET ``name`` = &1 RETURNING ``planets``.``name``"
        )
        try expectSerialization(
            of: db.delete(from: "planets").returning("*"),
            is: "DELETE FROM ``planets`` RETURNING *"
        )

        db._dialect.supportsReturning = false

        try expectSerialization(
            of: db.insert(into: "planets").columns("name").values("Jupiter").returning("id", "name"),
            is: "INSERT INTO ``planets`` (``name``) VALUES (&1)"
        )
        try expectSerialization(
            of: db.update("planets").set("name", to: "Jupiter").returning(SQLColumn("name", table: "planets")),
            is: "UPDATE ``planets`` SET ``name`` = &1"
        )
        try expectSerialization(
            of: db.delete(from: "planets").returning("*"),
            is: "DELETE FROM ``planets``"
        )
    }
}
