import SQLKit
import XCTest

final class SQLDialectFeatureTests: XCTestCase {
    var db = TestDatabase()

    override class func setUp() {
        XCTAssert(isLoggingConfigured)
    }
    
    // MARK: Dialect-Specific Behaviors

    func testIfExists() {
        self.db._dialect.supportsIfExists = true
        XCTAssertSerialization(of: self.db.create(table: "planets").ifNotExists(),     is: "CREATE TABLE IF NOT EXISTS ``planets``")
        XCTAssertSerialization(of: self.db.drop(table: "planets").ifExists(),          is: "DROP TABLE IF EXISTS ``planets``")
        XCTAssertSerialization(of: self.db.drop(index: "planets_name_idx").ifExists(), is: "DROP INDEX IF EXISTS ``planets_name_idx``")
        XCTAssertSerialization(of: self.db.drop(enum: "planet_types").ifExists(),      is: "DROP TYPE IF EXISTS ``planet_types`` RESTRICT")

        self.db._dialect.supportsIfExists = false
        XCTAssertSerialization(of: self.db.create(table: "planets").ifNotExists(),     is: "CREATE TABLE ``planets``")
        XCTAssertSerialization(of: self.db.drop(table: "planets").ifExists(),          is: "DROP TABLE ``planets``")
        XCTAssertSerialization(of: self.db.drop(index: "planets_name_idx").ifExists(), is: "DROP INDEX ``planets_name_idx``")
        XCTAssertSerialization(of: self.db.drop(enum: "planet_types").ifExists(),      is: "DROP TYPE ``planet_types`` RESTRICT")
    }

    func testDropBehavior() {
        self.db._dialect.supportsDropBehavior = false
        XCTAssertSerialization(of: self.db.drop(table: "planets"),                              is: "DROP TABLE ``planets``")
        XCTAssertSerialization(of: self.db.drop(index: "planets_name_idx"),                     is: "DROP INDEX ``planets_name_idx``")
        XCTAssertSerialization(of: self.db.drop(enum: "planet_types"),                          is: "DROP TYPE ``planet_types``")
        XCTAssertSerialization(of: self.db.drop(table: "planets").behavior(.cascade),           is: "DROP TABLE ``planets``")
        XCTAssertSerialization(of: self.db.drop(index: "planets_name_idx").behavior(.cascade),  is: "DROP INDEX ``planets_name_idx``")
        XCTAssertSerialization(of: self.db.drop(enum: "planet_types").behavior(.cascade),       is: "DROP TYPE ``planet_types``")
        XCTAssertSerialization(of: self.db.drop(table: "planets").behavior(.restrict),          is: "DROP TABLE ``planets``")
        XCTAssertSerialization(of: self.db.drop(index: "planets_name_idx").behavior(.restrict), is: "DROP INDEX ``planets_name_idx``")
        XCTAssertSerialization(of: self.db.drop(enum: "planet_types").behavior(.restrict),      is: "DROP TYPE ``planet_types``")
        XCTAssertSerialization(of: self.db.drop(table: "planets").cascade(),                    is: "DROP TABLE ``planets``")
        XCTAssertSerialization(of: self.db.drop(index: "planets_name_idx").cascade(),           is: "DROP INDEX ``planets_name_idx``")
        XCTAssertSerialization(of: self.db.drop(enum: "planet_types").cascade(),                is: "DROP TYPE ``planet_types``")
        XCTAssertSerialization(of: self.db.drop(table: "planets").restrict(),                   is: "DROP TABLE ``planets``")
        XCTAssertSerialization(of: self.db.drop(index: "planets_name_idx").restrict(),          is: "DROP INDEX ``planets_name_idx``")
        XCTAssertSerialization(of: self.db.drop(enum: "planet_types").restrict(),               is: "DROP TYPE ``planet_types``")

        self.db._dialect.supportsDropBehavior = true
        XCTAssertSerialization(of: self.db.drop(table: "planets"),                              is: "DROP TABLE ``planets``")
        XCTAssertSerialization(of: self.db.drop(index: "planets_name_idx"),                     is: "DROP INDEX ``planets_name_idx``")
        XCTAssertSerialization(of: self.db.drop(enum: "planet_types"),                          is: "DROP TYPE ``planet_types`` RESTRICT")
        XCTAssertSerialization(of: self.db.drop(table: "planets").behavior(.cascade),           is: "DROP TABLE ``planets`` CASCADE")
        XCTAssertSerialization(of: self.db.drop(index: "planets_name_idx").behavior(.cascade),  is: "DROP INDEX ``planets_name_idx`` CASCADE")
        XCTAssertSerialization(of: self.db.drop(enum: "planet_types").behavior(.cascade),       is: "DROP TYPE ``planet_types`` CASCADE")
        XCTAssertSerialization(of: self.db.drop(table: "planets").behavior(.restrict),          is: "DROP TABLE ``planets`` RESTRICT")
        XCTAssertSerialization(of: self.db.drop(index: "planets_name_idx").behavior(.restrict), is: "DROP INDEX ``planets_name_idx`` RESTRICT")
        XCTAssertSerialization(of: self.db.drop(enum: "planet_types").behavior(.restrict),      is: "DROP TYPE ``planet_types`` RESTRICT")
        XCTAssertSerialization(of: self.db.drop(table: "planets").cascade(),                    is: "DROP TABLE ``planets`` CASCADE")
        XCTAssertSerialization(of: self.db.drop(index: "planets_name_idx").cascade(),           is: "DROP INDEX ``planets_name_idx`` CASCADE")
        XCTAssertSerialization(of: self.db.drop(enum: "planet_types").cascade(),                is: "DROP TYPE ``planet_types`` CASCADE")
        XCTAssertSerialization(of: self.db.drop(table: "planets").restrict(),                   is: "DROP TABLE ``planets`` RESTRICT")
        XCTAssertSerialization(of: self.db.drop(index: "planets_name_idx").restrict(),          is: "DROP INDEX ``planets_name_idx`` RESTRICT")
        XCTAssertSerialization(of: self.db.drop(enum: "planet_types").restrict(),               is: "DROP TYPE ``planet_types`` RESTRICT")
    }
    
    func testDropTemporary() {
        XCTAssertSerialization(
            of: self.db.drop(table: "normalized_planet_names").temporary(),
            is: "DROP TEMPORARY TABLE ``normalized_planet_names``"
        )
    }
    
    func testOwnerObjectsForDropIndex() {
        XCTAssertSerialization(
            of: self.db.drop(index: "some_crummy_mysql_index").on("some_darn_mysql_table"),
            is: "DROP INDEX ``some_crummy_mysql_index`` ON ``some_darn_mysql_table``"
        )
    }

    func testAlterTableSyntax() {
        // SINGLE
        XCTAssertSerialization(
            of: self.db.alter(table: "alterable").column("hello", type: .text),
            is: "ALTER TABLE ``alterable`` ADD ``hello`` TEXT"
        )
        XCTAssertSerialization(
            of: self.db.alter(table: "alterable").column(SQLIdentifier("hello"), type: SQLDataType.text),
            is: "ALTER TABLE ``alterable`` ADD ``hello`` TEXT"
        )
        XCTAssertSerialization(
            of: self.db.alter(table: "alterable").dropColumn("hello"),
            is: "ALTER TABLE ``alterable`` DROP ``hello``"
        )
        XCTAssertSerialization(
            of: self.db.alter(table: "alterable").modifyColumn("hello", type: .text),
            is: "ALTER TABLE ``alterable`` MOODIFY ``hello`` TEXT"
        )
        XCTAssertSerialization(
            of: self.db.alter(table: "alterable").modifyColumn(SQLIdentifier("hello"), type: SQLDataType.text),
            is: "ALTER TABLE ``alterable`` MOODIFY ``hello`` TEXT"
        )

        // BATCH
        XCTAssertSerialization(
            of: self.db.alter(table: "alterable").column("hello", type: .text).column("there", type: .text),
            is: "ALTER TABLE ``alterable`` ADD ``hello`` TEXT , ADD ``there`` TEXT"
        )
        XCTAssertSerialization(
            of: self.db.alter(table: "alterable").dropColumn("hello").dropColumn("there"),
            is: "ALTER TABLE ``alterable`` DROP ``hello`` , DROP ``there``"
        )
        XCTAssertSerialization(
            of: self.db.alter(table: "alterable").update(column: "hello", type: .text).update(column: "there", type: .text),
            is: "ALTER TABLE ``alterable`` MOODIFY ``hello`` TEXT , MOODIFY ``there`` TEXT"
        )

        // MIXED
        XCTAssertSerialization(
            of: self.db.alter(table: "alterable").column("hello", type: .text).dropColumn("there").update(column: "again", type: .text),
            is: "ALTER TABLE ``alterable`` ADD ``hello`` TEXT , DROP ``there`` , MOODIFY ``again`` TEXT"
        )

        // Table renaming
        XCTAssertSerialization(
            of: self.db.alter(table: "alterable").rename(to: "new_alterable"),
            is: "ALTER TABLE ``alterable`` RENAME TO ``new_alterable``"
        )
    }
    
    // MARK: Returning

    func testReturning() {
        self.db._dialect.supportsReturning = true

        XCTAssertSerialization(
            of: self.db.insert(into: "planets").columns("name").values("Jupiter").returning("id", "name"),
            is: "INSERT INTO ``planets`` (``name``) VALUES (&1) RETURNING ``id``, ``name``"
        )
        XCTAssertSerialization(
            of: self.db.update("planets").set("name", to: "Jupiter").returning(SQLColumn("name", table: "planets")),
            is: "UPDATE ``planets`` SET ``name`` = &1 RETURNING ``planets``.``name``"
        )
        XCTAssertSerialization(
            of: self.db.delete(from: "planets").returning("*"),
            is: "DELETE FROM ``planets`` RETURNING *"
        )

        self.db._dialect.supportsReturning = false

        XCTAssertSerialization(
            of: self.db.insert(into: "planets").columns("name").values("Jupiter").returning("id", "name"),
            is: "INSERT INTO ``planets`` (``name``) VALUES (&1)"
        )
        XCTAssertSerialization(
            of: self.db.update("planets").set("name", to: "Jupiter").returning(SQLColumn("name", table: "planets")),
            is: "UPDATE ``planets`` SET ``name`` = &1"
        )
        XCTAssertSerialization(
            of: self.db.delete(from: "planets").returning("*"),
            is: "DELETE FROM ``planets``"
        )
    }
}
