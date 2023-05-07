import SQLKit
import SQLKitBenchmark
import XCTest

final class SQLKitTests: XCTestCase {
    var db: TestDatabase!

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.db = TestDatabase()
    }
    
    // MARK: SQLBenchmark

    func testBenchmark() throws {
        let benchmarker = SQLBenchmarker(on: db)
        try benchmarker.run()
    }
    
    // MARK: Basic Queries
    
    func testSelect_tableAllCols() throws {
        try db.select().column(table: "planets", column: "*")
            .from("planets")
            .where("name", .equal, SQLBind("Earth"))
            .run().wait()
        XCTAssertEqual(db.results[0], "SELECT `planets`.* FROM `planets` WHERE `name` = ?")
    }
    
    func testSelect_whereEncodable() throws {
        try db.select().column("*")
            .from("planets")
            .where("name", .equal, "Earth")
            .orWhere("name", .equal, "Mars")
            .run().wait()
        XCTAssertEqual(db.results[0], "SELECT * FROM `planets` WHERE `name` = ? OR `name` = ?")
    }
    
    func testSelect_whereList() throws {
        try db.select().column("*")
            .from("planets")
            .where("name", .in, ["Earth", "Mars"])
            .orWhere("name", .in, ["Venus", "Mercury"])
            .run().wait()
        XCTAssertEqual(db.results[0], "SELECT * FROM `planets` WHERE `name` IN (?, ?) OR `name` IN (?, ?)")
    }

    func testSelect_whereGroup() throws {
        try db.select().column("*")
            .from("planets")
            .where {
                $0.where("name", .equal, "Earth")
                    .orWhere("name", .equal, "Mars")
            }
            .where("color", .equal, "blue")
            .run().wait()
        XCTAssertEqual(db.results[0], "SELECT * FROM `planets` WHERE (`name` = ? OR `name` = ?) AND `color` = ?")
    }
    
    func testSelect_whereColumn() throws {
        try db.select().column("*")
            .from("planets")
            .where("name", .notEqual, column: "color")
            .orWhere("name", .equal, column: "greekName")
            .run().wait()
        XCTAssertEqual(db.results[0], "SELECT * FROM `planets` WHERE `name` <> `color` OR `name` = `greekName`")
	}
	
    func testSelect_withoutFrom() throws {
        try db.select()
            .column(SQLAlias.init(SQLFunction("LAST_INSERT_ID"), as: SQLIdentifier.init("id")))
            .run()
            .wait()
        XCTAssertEqual(db.results[0], "SELECT LAST_INSERT_ID() AS `id`")
    }
    
    func testSelect_limitAndOrder() throws {
        try db.select()
            .column("*")
            .from("planets")
            .limit(3)
            .offset(5)
            .orderBy("name")
            .run()
            .wait()
        XCTAssertEqual(db.results[0], "SELECT * FROM `planets` ORDER BY `name` ASC LIMIT 3 OFFSET 5")
    }
    
    func testUpdate() throws {
        try db.update("planets")
            .where("name", .equal, "Jpuiter")
            .set("name", to: "Jupiter")
            .run().wait()
        XCTAssertEqual(db.results[0], "UPDATE `planets` SET `name` = ? WHERE `name` = ?")
    }

    func testDelete() throws {
        try db.delete(from: "planets")
            .where("name", .equal, "Jupiter")
            .run().wait()
        XCTAssertEqual(db.results[0], "DELETE FROM `planets` WHERE `name` = ?")
    }
    
    // MARK: Locking Clauses
    
    func testLockingClause_forUpdate() throws {
        try db.select().column("*")
            .from("planets")
            .where("name", .equal, "Earth")
            .for(.update)
            .run().wait()
        XCTAssertEqual(db.results[0], "SELECT * FROM `planets` WHERE `name` = ? FOR UPDATE")
    }
    
    func testLockingClause_forShare() throws {
        try db.select().column("*")
            .from("planets")
            .where("name", .equal, "Earth")
            .for(.share)
            .run().wait()
        XCTAssertEqual(db.results[0], "SELECT * FROM `planets` WHERE `name` = ? FOR SHARE")
    }
    
    func testLockingClause_raw() throws {
        try db.select().column("*")
            .from("planets")
            .where("name", .equal, "Earth")
            .lockingClause(SQLRaw("LOCK IN SHARE MODE"))
            .run().wait()
        XCTAssertEqual(db.results[0], "SELECT * FROM `planets` WHERE `name` = ? LOCK IN SHARE MODE")
    }
    
    // MARK: Group By/Having
    
    func testGroupByHaving() throws {
        try db.select().column("*")
            .from("planets")
            .groupBy("color")
            .having("color", .equal, "blue")
            .run().wait()
        XCTAssertEqual(db.results[0], "SELECT * FROM `planets` GROUP BY `color` HAVING `color` = ?")
    }
    
    // MARK: Dialect-Specific Behaviors

    func testIfExists() throws {
        try db.drop(table: "planets").ifExists().run().wait()
        XCTAssertEqual(db.results[0], "DROP TABLE IF EXISTS `planets`")

        try db.drop(index: "planets_name_idx").ifExists().run().wait()
        XCTAssertEqual(db.results[1], "DROP INDEX IF EXISTS `planets_name_idx`")

        db._dialect.supportsIfExists = false
        
        try db.drop(table: "planets").ifExists().run().wait()
        XCTAssertEqual(db.results[2], "DROP TABLE `planets`")

        try db.drop(index: "planets_name_idx").ifExists().run().wait()
        XCTAssertEqual(db.results[3], "DROP INDEX `planets_name_idx`")
    }

    func testDropBehavior() throws {
        try db.drop(table: "planets").run().wait()
        XCTAssertEqual(db.results[0], "DROP TABLE `planets`")

        try db.drop(index: "planets_name_idx").run().wait()
        XCTAssertEqual(db.results[1], "DROP INDEX `planets_name_idx`")

        try db.drop(table: "planets").behavior(.cascade).run().wait()
        XCTAssertEqual(db.results[2], "DROP TABLE `planets`")

        try db.drop(index: "planets_name_idx").behavior(.cascade).run().wait()
        XCTAssertEqual(db.results[3], "DROP INDEX `planets_name_idx`")

        try db.drop(table: "planets").behavior(.restrict).run().wait()
        XCTAssertEqual(db.results[4], "DROP TABLE `planets`")

        try db.drop(index: "planets_name_idx").behavior(.restrict).run().wait()
        XCTAssertEqual(db.results[5], "DROP INDEX `planets_name_idx`")

        try db.drop(table: "planets").cascade().run().wait()
        XCTAssertEqual(db.results[6], "DROP TABLE `planets`")

        try db.drop(index: "planets_name_idx").cascade().run().wait()
        XCTAssertEqual(db.results[7], "DROP INDEX `planets_name_idx`")

        try db.drop(table: "planets").restrict().run().wait()
        XCTAssertEqual(db.results[8], "DROP TABLE `planets`")

        try db.drop(index: "planets_name_idx").restrict().run().wait()
        XCTAssertEqual(db.results[9], "DROP INDEX `planets_name_idx`")

        db._dialect.supportsDropBehavior = true
        
        try db.drop(table: "planets").run().wait()
        XCTAssertEqual(db.results[10], "DROP TABLE `planets` RESTRICT")

        try db.drop(index: "planets_name_idx").run().wait()
        XCTAssertEqual(db.results[11], "DROP INDEX `planets_name_idx` RESTRICT")

        try db.drop(table: "planets").behavior(.cascade).run().wait()
        XCTAssertEqual(db.results[12], "DROP TABLE `planets` CASCADE")

        try db.drop(index: "planets_name_idx").behavior(.cascade).run().wait()
        XCTAssertEqual(db.results[13], "DROP INDEX `planets_name_idx` CASCADE")

        try db.drop(table: "planets").behavior(.restrict).run().wait()
        XCTAssertEqual(db.results[14], "DROP TABLE `planets` RESTRICT")

        try db.drop(index: "planets_name_idx").behavior(.restrict).run().wait()
        XCTAssertEqual(db.results[15], "DROP INDEX `planets_name_idx` RESTRICT")

        try db.drop(table: "planets").cascade().run().wait()
        XCTAssertEqual(db.results[16], "DROP TABLE `planets` CASCADE")

        try db.drop(index: "planets_name_idx").cascade().run().wait()
        XCTAssertEqual(db.results[17], "DROP INDEX `planets_name_idx` CASCADE")

        try db.drop(table: "planets").restrict().run().wait()
        XCTAssertEqual(db.results[18], "DROP TABLE `planets` RESTRICT")

        try db.drop(index: "planets_name_idx").restrict().run().wait()
        XCTAssertEqual(db.results[19], "DROP INDEX `planets_name_idx` RESTRICT")
    }
    
    func testDropTemporary() throws {
        try db.drop(table: "normalized_planet_names").temporary().run().wait()
        XCTAssertEqual(db.results[0], "DROP TEMPORARY TABLE `normalized_planet_names`")
    }
    
    func testOwnerObjectsForDropIndex() throws {
        try db.drop(index: "some_crummy_mysql_index").on("some_darn_mysql_table").run().wait()
        XCTAssertEqual(db.results[0], "DROP INDEX `some_crummy_mysql_index` ON `some_darn_mysql_table`")
    }

    func testAltering() throws {
        // SINGLE
        try db.alter(table: "alterable")
            .column("hello", type: .text)
            .run().wait()
        XCTAssertEqual(db.results[0], "ALTER TABLE `alterable` ADD `hello` TEXT")

        try db.alter(table: "alterable")
            .dropColumn("hello")
            .run().wait()
        XCTAssertEqual(db.results[1], "ALTER TABLE `alterable` DROP `hello`")

        try db.alter(table: "alterable")
            .modifyColumn("hello", type: .text)
            .run().wait()
        XCTAssertEqual(db.results[2], "ALTER TABLE `alterable` MODIFY `hello` TEXT")

        // BATCH
        try db.alter(table: "alterable")
            .column("hello", type: .text)
            .column("there", type: .text)
            .run().wait()
        XCTAssertEqual(db.results[3], "ALTER TABLE `alterable` ADD `hello` TEXT , ADD `there` TEXT")

        try db.alter(table: "alterable")
            .dropColumn("hello")
            .dropColumn("there")
            .run().wait()
        XCTAssertEqual(db.results[4], "ALTER TABLE `alterable` DROP `hello` , DROP `there`")

        try db.alter(table: "alterable")
            .update(column: "hello", type: .text)
            .update(column: "there", type: .text)
            .run().wait()
        XCTAssertEqual(db.results[5], "ALTER TABLE `alterable` MODIFY `hello` TEXT , MODIFY `there` TEXT")

        // MIXED
        try db.alter(table: "alterable")
            .column("hello", type: .text)
            .dropColumn("there")
            .update(column: "again", type: .text)
            .run().wait()
        XCTAssertEqual(db.results[6], "ALTER TABLE `alterable` ADD `hello` TEXT , DROP `there` , MODIFY `again` TEXT")

        // Table renaming
        try db.alter(table: "alterable")
            .rename(to: "new_alterable")
            .run().wait()
        XCTAssertEqual(db.results[7], "ALTER TABLE `alterable` RENAME TO `new_alterable`")
    }
    
    // MARK: Distinct
    
    func testDistinct() throws {
        try db.select().column("*")
            .from("planets")
            .groupBy("color")
            .having("color", .equal, "blue")
            .distinct()
            .run().wait()
        XCTAssertEqual(db.results[0], "SELECT DISTINCT * FROM `planets` GROUP BY `color` HAVING `color` = ?")
    }
    
    func testDistinctColumns() throws {
        try db.select()
            .distinct(on: "name", "color")
            .from("planets")
            .run().wait()
        XCTAssertEqual(db.results[0], "SELECT DISTINCT `name`, `color` FROM `planets`")
    }
    
    func testDistinctExpression() throws {
        try db.select()
            .column(SQLFunction("COUNT", args: SQLDistinct("name", "color")))
            .from("planets")
            .run().wait()
        XCTAssertEqual(db.results[0], "SELECT COUNT(DISTINCT(`name`, `color`)) FROM `planets`")
    }
    
    // MARK: Joins
    
    func testSimpleJoin() throws {
        try db.select().column("*")
            .from("planets")
            .join("moons", on: "\(ident: "moons").\(ident: "planet_id")=\(ident: "planets").\(ident: "id")" as SQLQueryString)
            .run().wait()
        
        XCTAssertEqual(db.results[0], "SELECT * FROM `planets` INNER JOIN `moons` ON `moons`.`planet_id`=`planets`.`id`")
    }
    
    func testMessyJoin() throws {
        try db.select().column("*")
            .from("planets")
            .join(
                SQLAlias(SQLGroupExpression(
                    db.select().column("name").from("stars").where(SQLColumn("orion"), .equal, SQLIdentifier("please space")).select
                ), as: SQLIdentifier("star")),
                method: SQLJoinMethod.outer,
                on: SQLColumn(SQLIdentifier("planet_id"), table: SQLIdentifier("moons")), SQLBinaryOperator.isNot, SQLRaw("%%%%%%")
            )
            .where(SQLLiteral.null)
            .run().wait()
        
        // Yes, this query is very much pure gibberish.
        XCTAssertEqual(db.results[0], "SELECT * FROM `planets` OUTER JOIN (SELECT `name` FROM `stars` WHERE `orion` = `please space`) AS `star` ON `moons`.`planet_id` IS NOT %%%%%% WHERE NULL")
    }
    
    // MARK: Operators
    
    func testBinaryOperators() throws {
        try db
            .update("planets")
            .set(SQLIdentifier("moons"),
                 to: SQLBinaryExpression(
                    left: SQLIdentifier("moons"),
                    op: SQLBinaryOperator.add,
                    right: SQLLiteral.numeric("1")
                )
            )
            .where("best_at_space", .greaterThanOrEqual, "yes")
            .run().wait()
        
        XCTAssertEqual(db.results[0], "UPDATE `planets` SET `moons` = `moons` + 1 WHERE `best_at_space` >= ?")
    }
    
    func testInsertWithArrayOfEncodable() throws {
        func weird<S: Sequence>(_ builder: SQLInsertBuilder, values: S) -> SQLInsertBuilder where S.Element: Encodable {
            builder.values(Array(values))
        }
        
        try weird(db.insert(into: "planets")
            .columns("name"),
            values: ["Jupiter"]
        ).run().wait()
        XCTAssertEqual(db.results[0], "INSERT INTO `planets` (`name`) VALUES (?)")
        XCTAssertEqual(db.bindResults[0] as? [String], ["Jupiter"]) // instead of [["Jupiter"]]
    }

    // MARK: Returning

    func testReturning() throws {
        try db.insert(into: "planets")
            .columns("name")
            .values("Jupiter")
            .returning("id", "name")
            .run().wait()
        XCTAssertEqual(db.results[0], "INSERT INTO `planets` (`name`) VALUES (?) RETURNING `id`, `name`")

        _ = try db.update("planets")
            .set("name", to: "Jupiter")
            .returning(SQLColumn("name", table: "planets"))
            .first().wait()
        XCTAssertEqual(db.results[1], "UPDATE `planets` SET `name` = ? RETURNING `planets`.`name`")

        _ = try db.delete(from: "planets")
            .returning("*")
            .all().wait()
        XCTAssertEqual(db.results[2], "DELETE FROM `planets` RETURNING *")
    }
    
    // MARK: Upsert
    
    func testUpsert() throws {
        // Test the thoroughly underpowered and inconvenient MySQL syntax first
        db._dialect.upsertSyntax = .mysqlLike
        
        let cols = ["id", "serial_number", "star_id", "last_known_status"]
        let vals = { (s: String) -> [SQLExpression] in [SQLLiteral.default, SQLBind(UUID()), SQLBind(1), SQLBind(s)] }
        
        try db.insert(into: "jumpgates").columns(cols).values(vals("calibration"))
            .run().wait()
        try db.insert(into: "jumpgates").columns(cols).values(vals("unicorn dust application"))
            .ignoringConflicts()
            .run().wait()
        try db.insert(into: "jumpgates").columns(cols).values(vals("planet-size snake oil jar purchasing"))
            .onConflict() { $0
                .set("last_known_status", to: "Hooloovoo engineer refraction")
                .set(excludedValueOf: "serial_number")
            }
            .run().wait()
        
        XCTAssertEqual(db.results[0], "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?)")
        XCTAssertEqual(db.results[1], "INSERT IGNORE INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?)")
        XCTAssertEqual(db.results[2], "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?) ON DUPLICATE KEY UPDATE `last_known_status` = ?, `serial_number` = VALUES(`serial_number`)")
        
        // Now the standard SQL syntax
        db._dialect.upsertSyntax = .standard
        
        try db.insert(into: "jumpgates").columns(cols).values(vals("calibration"))
            .run().wait()
        try db.insert(into: "jumpgates").columns(cols).values(vals("unicorn dust application"))
            .ignoringConflicts()
            .run().wait()
        try db.insert(into: "jumpgates").columns(cols).values(vals("Vorlon pinching"))
            .ignoringConflicts(with: ["serial_number", "star_id"])
            .run().wait()
        try db.insert(into: "jumpgates").columns(cols).values(vals("planet-size snake oil jar purchasing"))
            .onConflict() { $0
                .set("last_known_status", to: "Hooloovoo engineer refraction").set(excludedValueOf: "serial_number")
            }
            .run().wait()
        try db.insert(into: "jumpgates").columns(cols).values(vals("slashfic writing"))
            .onConflict(with: ["serial_number"]) { $0
                .set("last_known_status", to: "tachyon antitelephone dialing the").set(excludedValueOf: "star_id")
            }
            .run().wait()
        try db.insert(into: "jumpgates").columns(cols).values(vals("protection racket payoff"))
            .onConflict(with: ["id"]) { $0
                .set("last_known_status", to: "insurance fraud planning")
                .where("last_known_status", .notEqual, "evidence disposal")
            }
            .run().wait()

        XCTAssertEqual(db.results[3], "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?)")
        XCTAssertEqual(db.results[4], "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?) ON CONFLICT DO NOTHING")
        XCTAssertEqual(db.results[5], "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?) ON CONFLICT (`serial_number`, `star_id`) DO NOTHING")
        XCTAssertEqual(db.results[6], "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?) ON CONFLICT DO UPDATE SET `last_known_status` = ?, `serial_number` = EXCLUDED.`serial_number`")
        XCTAssertEqual(db.results[7], "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?) ON CONFLICT (`serial_number`) DO UPDATE SET `last_known_status` = ?, `star_id` = EXCLUDED.`star_id`")
        XCTAssertEqual(db.results[8], "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?) ON CONFLICT (`id`) DO UPDATE SET `last_known_status` = ? WHERE `last_known_status` <> ?")
    }
    
    // MARK: Codable Nullity

    func testCodableWithNillableColumnWithSomeValue() throws {
        struct Gas: Codable {
            let name: String
            let color: String?
        }
        let db = TestDatabase()
        var serializer = SQLSerializer(database: db)

        let insertBuilder = try db.insert(into: "gasses").model(Gas(name: "iodine", color: "purple"))
        insertBuilder.insert.serialize(to: &serializer)

        XCTAssertEqual(serializer.sql, "INSERT INTO `gasses` (`name`, `color`) VALUES (?, ?)")
        XCTAssertEqual(serializer.binds.count, 2)
        XCTAssertEqual(serializer.binds[0] as? String, "iodine")
        XCTAssertEqual(serializer.binds[1] as? String, "purple")
    }

    func testCodableWithNillableColumnWithNilValueWithoutNilEncodingStrategy() throws {
        struct Gas: Codable {
            let name: String
            let color: String?
        }
        let db = TestDatabase()
        var serializer = SQLSerializer(database: db)

        let insertBuilder = try db.insert(into: "gasses").model(Gas(name: "oxygen", color: nil))
        insertBuilder.insert.serialize(to: &serializer)

        XCTAssertEqual(serializer.sql, "INSERT INTO `gasses` (`name`) VALUES (?)")
        XCTAssertEqual(serializer.binds.count, 1)
        XCTAssertEqual(serializer.binds[0] as? String, "oxygen")
    }

    func testCodableWithNillableColumnWithNilValueAndNilEncodingStrategy() throws {
        struct Gas: Codable {
            let name: String
            let color: String?
        }
        let db = TestDatabase()
        var serializer = SQLSerializer(database: db)

        let insertBuilder = try db.insert(into: "gasses").model(Gas(name: "oxygen", color: nil), nilEncodingStrategy: .asNil)
        insertBuilder.insert.serialize(to: &serializer)

        XCTAssertEqual(serializer.sql, "INSERT INTO `gasses` (`name`, `color`) VALUES (?, NULL)")
        XCTAssertEqual(serializer.binds.count, 1)
        XCTAssertEqual(serializer.binds[0] as? String, "oxygen")
    }

    func testRawCustomStringConvertible() throws {
        let field = "name"
        let db = TestDatabase()
        _ = try db.raw("SELECT \(raw: field) FROM users").all().wait()
        XCTAssertEqual(db.results[0], "SELECT name FROM users")
    }

    // MARK: Table Creation

    func testColumnConstraints() throws {
        try db.create(table: "planets")
            .column("id", type: .bigint, .primaryKey)
            .column("name", type: .text, .default("unnamed"))
            .column("galaxy_id", type: .bigint, .references("galaxies", "id"))
            .column("diameter", type: .int, .check(SQLRaw("diameter > 0")))
            .column("important", type: .text, .notNull)
            .column("special", type: .text, .unique)
            .column("automatic", type: .text, .generated(SQLRaw("CONCAT(name, special)")))
            .column("collated", type: .text, .collate(name: "default"))
            .run().wait()

        XCTAssertEqual(db.results[0],
"""
CREATE TABLE `planets`(`id` BIGINT PRIMARY KEY AUTOINCREMENT, `name` TEXT DEFAULT 'unnamed', `galaxy_id` BIGINT REFERENCES `galaxies` (`id`), `diameter` INTEGER CHECK (diameter > 0), `important` TEXT NOT NULL, `special` TEXT UNIQUE, `automatic` TEXT GENERATED ALWAYS AS (CONCAT(name, special)) STORED, `collated` TEXT COLLATE `default`)
"""
                       )
    }
    
    func testConstraintLengthNormalization() {
        // Default impl is to leave as-is
        XCTAssertEqual(
            (db.dialect.normalizeSQLConstraint(identifier: SQLIdentifier("fk:obnoxiously_long_table_name.other_table_name_id+other_table_name.id")) as! SQLIdentifier).string,
            SQLIdentifier("fk:obnoxiously_long_table_name.other_table_name_id+other_table_name.id").string
        )
    }

    func testMultipleColumnConstraintsPerRow() throws {
        try db.create(table: "planets")
            .column("id", type: .bigint, .notNull, .primaryKey)
            .run().wait()

        XCTAssertEqual(db.results[0], "CREATE TABLE `planets`(`id` BIGINT NOT NULL PRIMARY KEY AUTOINCREMENT)")
    }

    func testPrimaryKeyColumnConstraintVariants() throws {
        try db.create(table: "planets1")
            .column("id", type: .bigint, .primaryKey)
            .run().wait()

        try db.create(table: "planets2")
            .column("id", type: .bigint, .primaryKey(autoIncrement: false))
            .run().wait()

        XCTAssertEqual(db.results[0], "CREATE TABLE `planets1`(`id` BIGINT PRIMARY KEY AUTOINCREMENT)")

        XCTAssertEqual(db.results[1], "CREATE TABLE `planets2`(`id` BIGINT PRIMARY KEY)")
    }

    func testPrimaryKeyAutoIncrementVariants() throws {
        db._dialect.supportsAutoIncrement = false

        try db.create(table: "planets1")
            .column("id", type: .bigint, .primaryKey)
            .run().wait()

        try db.create(table: "planets2")
            .column("id", type: .bigint, .primaryKey(autoIncrement: false))
            .run().wait()

        db._dialect.supportsAutoIncrement = true

        try db.create(table: "planets3")
            .column("id", type: .bigint, .primaryKey)
            .run().wait()

        try db.create(table: "planets4")
            .column("id", type: .bigint, .primaryKey(autoIncrement: false))
            .run().wait()

        db._dialect.supportsAutoIncrement = true
        db._dialect.autoIncrementFunction = SQLRaw("NEXTUNIQUE")

        try db.create(table: "planets5")
            .column("id", type: .bigint, .primaryKey)
            .run().wait()

        try db.create(table: "planets6")
            .column("id", type: .bigint, .primaryKey(autoIncrement: false))
            .run().wait()

        XCTAssertEqual(db.results[0], "CREATE TABLE `planets1`(`id` BIGINT PRIMARY KEY)")

        XCTAssertEqual(db.results[1], "CREATE TABLE `planets2`(`id` BIGINT PRIMARY KEY)")

        XCTAssertEqual(db.results[2], "CREATE TABLE `planets3`(`id` BIGINT PRIMARY KEY AUTOINCREMENT)")

        XCTAssertEqual(db.results[3], "CREATE TABLE `planets4`(`id` BIGINT PRIMARY KEY)")

        XCTAssertEqual(db.results[4], "CREATE TABLE `planets5`(`id` BIGINT DEFAULT NEXTUNIQUE PRIMARY KEY)")

        XCTAssertEqual(db.results[5], "CREATE TABLE `planets6`(`id` BIGINT PRIMARY KEY)")
    }

    func testDefaultColumnConstraintVariants() throws {
        try db.create(table: "planets1")
            .column("name", type: .text, .default("unnamed"))
            .run().wait()

        try db.create(table: "planets2")
            .column("diameter", type: .int, .default(10))
            .run().wait()

        try db.create(table: "planets3")
            .column("diameter", type: .real, .default(11.5))
            .run().wait()

        try db.create(table: "planets4")
            .column("current", type: .custom(SQLRaw("BOOLEAN")), .default(false))
            .run().wait()

        try db.create(table: "planets5")
            .column("current", type: .custom(SQLRaw("BOOLEAN")), .default(SQLLiteral.boolean(true)))
            .run().wait()

        XCTAssertEqual(db.results[0], "CREATE TABLE `planets1`(`name` TEXT DEFAULT 'unnamed')")

        XCTAssertEqual(db.results[1], "CREATE TABLE `planets2`(`diameter` INTEGER DEFAULT 10)")

        XCTAssertEqual(db.results[2], "CREATE TABLE `planets3`(`diameter` REAL DEFAULT 11.5)")

        XCTAssertEqual(db.results[3], "CREATE TABLE `planets4`(`current` BOOLEAN DEFAULT false)")

        XCTAssertEqual(db.results[4], "CREATE TABLE `planets5`(`current` BOOLEAN DEFAULT true)")
    }

    func testForeignKeyColumnConstraintVariants() throws {
        try db.create(table: "planets1")
            .column("galaxy_id", type: .bigint, .references("galaxies", "id"))
            .run().wait()

        try db.create(table: "planets2")
            .column("galaxy_id", type: .bigint, .references("galaxies", "id", onDelete: .cascade, onUpdate: .restrict))
            .run().wait()

        XCTAssertEqual(db.results[0], "CREATE TABLE `planets1`(`galaxy_id` BIGINT REFERENCES `galaxies` (`id`))")

        XCTAssertEqual(db.results[1], "CREATE TABLE `planets2`(`galaxy_id` BIGINT REFERENCES `galaxies` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT)")
    }

    func testTableConstraints() throws {
        try db.create(table: "planets")
            .column("id", type: .bigint)
            .column("name", type: .text)
            .column("diameter", type: .int)
            .column("galaxy_name", type: .text)
            .column("galaxy_id", type: .bigint)
            .primaryKey("id")
            .unique("name")
            .check(SQLRaw("diameter > 0"), named: "non-zero-diameter")
            .foreignKey(
                ["galaxy_id", "galaxy_name"],
                references: "galaxies",
                ["id", "name"]
            ).run().wait()

        XCTAssertEqual(db.results[0],
"""
CREATE TABLE `planets`(`id` BIGINT, `name` TEXT, `diameter` INTEGER, `galaxy_name` TEXT, `galaxy_id` BIGINT, PRIMARY KEY (`id`), UNIQUE (`name`), CONSTRAINT `non-zero-diameter` CHECK (diameter > 0), FOREIGN KEY (`galaxy_id`, `galaxy_name`) REFERENCES `galaxies` (`id`, `name`))
"""
                       )
    }

    func testCompositePrimaryKeyTableConstraint() throws {
        try db.create(table: "planets1")
            .column("id1", type: .bigint)
            .column("id2", type: .bigint)
            .primaryKey("id1", "id2")
            .run().wait()

        XCTAssertEqual(db.results[0], "CREATE TABLE `planets1`(`id1` BIGINT, `id2` BIGINT, PRIMARY KEY (`id1`, `id2`))")
    }

    func testCompositeUniqueTableConstraint() throws {
        try db.create(table: "planets1")
            .column("id1", type: .bigint)
            .column("id2", type: .bigint)
            .unique("id1", "id2")
            .run().wait()

        XCTAssertEqual(db.results[0], "CREATE TABLE `planets1`(`id1` BIGINT, `id2` BIGINT, UNIQUE (`id1`, `id2`))")
    }

    func testPrimaryKeyTableConstraintVariants() throws {
        try db.create(table: "planets1")
            .column("galaxy_name", type: .text)
            .column("galaxy_id", type: .bigint)
            .foreignKey(
                ["galaxy_id", "galaxy_name"],
                references: "galaxies",
                ["id", "name"]
        ).run().wait()

        try db.create(table: "planets2")
            .column("galaxy_id", type: .bigint)
            .foreignKey(
                ["galaxy_id"],
                references: "galaxies",
                ["id"]
        ).run().wait()

        try db.create(table: "planets3")
            .column("galaxy_id", type: .bigint)
            .foreignKey(
                ["galaxy_id"],
                references: "galaxies",
                ["id"],
                onDelete: .restrict,
                onUpdate: .cascade
        ).run().wait()

        XCTAssertEqual(db.results[0], "CREATE TABLE `planets1`(`galaxy_name` TEXT, `galaxy_id` BIGINT, FOREIGN KEY (`galaxy_id`, `galaxy_name`) REFERENCES `galaxies` (`id`, `name`))")

        XCTAssertEqual(db.results[1], "CREATE TABLE `planets2`(`galaxy_id` BIGINT, FOREIGN KEY (`galaxy_id`) REFERENCES `galaxies` (`id`))")

        XCTAssertEqual(db.results[2], "CREATE TABLE `planets3`(`galaxy_id` BIGINT, FOREIGN KEY (`galaxy_id`) REFERENCES `galaxies` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE)")
    }
    
    func testCreateTableAsSelectQuery() throws {
        try db.create(table: "normalized_planet_names")
            .column("id", type: .bigint, .primaryKey(autoIncrement: false), .notNull)
            .column("name", type: .text, .unique, .notNull)
            .select { $0
                .distinct()
                .column("id", as: "id")
                .column(SQLFunction("LOWER", args: SQLColumn("name")), as: "name")
                .from("planets")
                .where("galaxy_id", .equal, SQLBind(1))
            }
            .run().wait()
            
        XCTAssertEqual(db.results[0], "CREATE TABLE `normalized_planet_names`(`id` BIGINT PRIMARY KEY NOT NULL, `name` TEXT UNIQUE NOT NULL) AS SELECT DISTINCT `id` AS `id`, LOWER(`name`) AS `name` FROM `planets` WHERE `galaxy_id` = ?")
    }

    // MARK: Row Decoder
    
    func testSQLRowDecoder() throws {
        struct Foo: Codable {
            let id: UUID
            let foo: Int
            let bar: Double?
            let baz: String
            let waldoFred: Int?
        }

        struct FooWithForeignKey: Codable {
            let id: UUID
            let foo: Int
            let bar: Double?
            let baz: String
            let waldoFredID: Int
        }

        do {
            let row = TestRow(data: [
                "id": .some(UUID()),
                "foo": .some(42),
                "bar": .none,
                "baz": .some("vapor"),
                "waldoFred": .some(2015)
            ])

            let foo = try row.decode(model: Foo.self)
            XCTAssertEqual(foo.foo, 42)
            XCTAssertEqual(foo.bar, nil)
            XCTAssertEqual(foo.baz, "vapor")
            XCTAssertEqual(foo.waldoFred, 2015)
        } catch {
            XCTFail("Could not decode row \(error)")
        }
        do {
            let row = TestRow(data: [
                "foos_id": .some(UUID()),
                "foos_foo": .some(42),
                "foos_bar": .none,
                "foos_baz": .some("vapor"),
                "foos_waldoFred": .some(2015)
            ])

            let foo = try row.decode(model: Foo.self, prefix: "foos_")
            XCTAssertEqual(foo.foo, 42)
            XCTAssertEqual(foo.bar, nil)
            XCTAssertEqual(foo.baz, "vapor")
            XCTAssertEqual(foo.waldoFred, 2015)
        } catch {
            XCTFail("Could not decode row with prefix \(error)")
        }
        do {
            let row = TestRow(data: [
                "id": .some(UUID()),
                "foo": .some(42),
                "bar": .none,
                "baz": .some("vapor"),
                "waldo_fred": .some(2015)
            ])

            let foo = try row.decode(model: Foo.self, keyDecodingStrategy: .convertFromSnakeCase)
            XCTAssertEqual(foo.foo, 42)
            XCTAssertEqual(foo.bar, nil)
            XCTAssertEqual(foo.baz, "vapor")
            XCTAssertEqual(foo.waldoFred, 2015)
        } catch {
            XCTFail("Could not decode row with keyDecodingStrategy \(error)")
        }
        do {
            let row = TestRow(data: [
                "id": .some(UUID()),
                "foo": .some(42),
                "bar": .none,
                "baz": .some("vapor"),
                "waldoFredID": .some(2015)
            ])

            /// An implementation of CodingKey that's useful for combining and transforming keys as strings.
            struct AnyKey: CodingKey {
                var stringValue: String
                var intValue: Int?

                init?(stringValue: String) {
                    self.stringValue = stringValue
                    self.intValue = nil
                }

                init?(intValue: Int) {
                    self.stringValue = String(intValue)
                    self.intValue = intValue
                }
            }

            func decodeIdToID(_ keys: [CodingKey]) -> CodingKey {
                let keyString = keys.last!.stringValue

                if let range = keyString.range(of: "Id", options: [.anchored, .backwards]) {
                    return AnyKey(stringValue: keyString[..<range.lowerBound] + "ID")!
                }
                return keys.last!
            }

            let foo = try row.decode(model: FooWithForeignKey.self, keyDecodingStrategy: .custom(decodeIdToID))
            XCTAssertEqual(foo.foo, 42)
            XCTAssertEqual(foo.bar, nil)
            XCTAssertEqual(foo.baz, "vapor")
            XCTAssertEqual(foo.waldoFredID, 2015)
        } catch {
            XCTFail("Could not decode row with keyDecodingStrategy \(error)")
        }
    }

    func testUnions() throws {
        // Check that queries are explicitly malformed without the feature flags
        db._dialect.unionFeatures = []
        try db.select().column("id").from("t1").union(distinct: { $0.column("id").from("t2") }).run().wait()
        try db.select().column("id").from("t1").union(all: { $0.column("id").from("t2") }).run().wait()
        try db.select().column("id").from("t1").intersect(distinct: { $0.column("id").from("t2") }).run().wait()
        try db.select().column("id").from("t1").intersect(all: { $0.column("id").from("t2") }).run().wait()
        try db.select().column("id").from("t1").except(distinct: { $0.column("id").from("t2") }).run().wait()
        try db.select().column("id").from("t1").except(all: { $0.column("id").from("t2") }).run().wait()

        XCTAssertEqual(db.results[0],  "SELECT `id` FROM `t1`  SELECT `id` FROM `t2`")
        XCTAssertEqual(db.results[1],  "SELECT `id` FROM `t1`  SELECT `id` FROM `t2`")
        XCTAssertEqual(db.results[2],  "SELECT `id` FROM `t1`  SELECT `id` FROM `t2`")
        XCTAssertEqual(db.results[3],  "SELECT `id` FROM `t1`  SELECT `id` FROM `t2`")
        XCTAssertEqual(db.results[4],  "SELECT `id` FROM `t1`  SELECT `id` FROM `t2`")
        XCTAssertEqual(db.results[5],  "SELECT `id` FROM `t1`  SELECT `id` FROM `t2`")


        // Test that queries are correctly formed with the feature flags
        db._dialect.unionFeatures.formUnion([.union, .unionAll, .intersect, .intersectAll, .except, .exceptAll])
        try db.select().column("id").from("t1").union(distinct: { $0.column("id").from("t2") }).run().wait()
        try db.select().column("id").from("t1").union(all: { $0.column("id").from("t2") }).run().wait()
        try db.select().column("id").from("t1").intersect(distinct: { $0.column("id").from("t2") }).run().wait()
        try db.select().column("id").from("t1").intersect(all: { $0.column("id").from("t2") }).run().wait()
        try db.select().column("id").from("t1").except(distinct: { $0.column("id").from("t2") }).run().wait()
        try db.select().column("id").from("t1").except(all: { $0.column("id").from("t2") }).run().wait()
        
        XCTAssertEqual(db.results[6],  "SELECT `id` FROM `t1` UNION SELECT `id` FROM `t2`")
        XCTAssertEqual(db.results[7],  "SELECT `id` FROM `t1` UNION ALL SELECT `id` FROM `t2`")
        XCTAssertEqual(db.results[8],  "SELECT `id` FROM `t1` INTERSECT SELECT `id` FROM `t2`")
        XCTAssertEqual(db.results[9],  "SELECT `id` FROM `t1` INTERSECT ALL SELECT `id` FROM `t2`")
        XCTAssertEqual(db.results[10], "SELECT `id` FROM `t1` EXCEPT SELECT `id` FROM `t2`")
        XCTAssertEqual(db.results[11], "SELECT `id` FROM `t1` EXCEPT ALL SELECT `id` FROM `t2`")


        // Test that the explicit distinct flag is respected
        db._dialect.unionFeatures.insert(.explicitDistinct)
        try db.select().column("id").from("t1").union(distinct: { $0.column("id").from("t2") }).run().wait()
        try db.select().column("id").from("t1").intersect(distinct: { $0.column("id").from("t2") }).run().wait()
        try db.select().column("id").from("t1").except(distinct: { $0.column("id").from("t2") }).run().wait()

        XCTAssertEqual(db.results[12], "SELECT `id` FROM `t1` UNION DISTINCT SELECT `id` FROM `t2`")
        XCTAssertEqual(db.results[13], "SELECT `id` FROM `t1` INTERSECT DISTINCT SELECT `id` FROM `t2`")
        XCTAssertEqual(db.results[14], "SELECT `id` FROM `t1` EXCEPT DISTINCT SELECT `id` FROM `t2`")


        // Test that the parenthesized subqueries flag does as expected, including for multiple unions
        db._dialect.unionFeatures.formSymmetricDifference([.explicitDistinct, .parenthesizedSubqueries])
        try db.select().column("id").from("t1").union(distinct: { $0.column("id").from("t2") }).run().wait()
        try db.select().column("id").from("t1")
              .union(distinct: { $0.column("id").from("t2") })
              .union(distinct: { $0.column("id").from("t3") })
              .run().wait()

        XCTAssertEqual(db.results[15], "(SELECT `id` FROM `t1`) UNION (SELECT `id` FROM `t2`)")
        XCTAssertEqual(db.results[16], "(SELECT `id` FROM `t1`) UNION (SELECT `id` FROM `t2`) UNION (SELECT `id` FROM `t3`)")


        // Test that chaining and mixing multiple union types works
        db._dialect.unionFeatures.insert(.explicitDistinct)
        try db.select().column("id").from("t1")
              .union(distinct:     { $0.column("id").from("t2") })
              .union(all:          { $0.column("id").from("t3") })
              .intersect(distinct: { $0.column("id").from("t4") })
              .intersect(all:      { $0.column("id").from("t5") })
              .except(distinct:    { $0.column("id").from("t6") })
              .except(all:         { $0.column("id").from("t7") })
              .run().wait()

        XCTAssertEqual(db.results[17], "(SELECT `id` FROM `t1`) UNION DISTINCT (SELECT `id` FROM `t2`) UNION ALL (SELECT `id` FROM `t3`) INTERSECT DISTINCT (SELECT `id` FROM `t4`) INTERSECT ALL (SELECT `id` FROM `t5`) EXCEPT DISTINCT (SELECT `id` FROM `t6`) EXCEPT ALL (SELECT `id` FROM `t7`)")
        
        // Test that having a single entry in the union just executes that entry
        try db.union { select in
            select.column("id").from("t1")
        }.run().wait()
        XCTAssertEqual(db.results[18], "SELECT `id` FROM `t1`")

        // Test LIMIT, OFFSET, and ORDERBY
        db._dialect.unionFeatures.remove(.explicitDistinct)
        try db.select()
            .column("id").from("t1")
            .union({
                $0.column("id").from("t2")
            })
            .limit(3)
            .offset(5)
            .orderBy("id")
            .run()
            .wait()
        XCTAssertEqual(db.results[19], "(SELECT `id` FROM `t1`) UNION (SELECT `id` FROM `t2`) ORDER BY `id` ASC LIMIT 3 OFFSET 5")
        
        // Test multiple ORDERBY statements
        db._dialect.unionFeatures.remove(.explicitDistinct)
        try db.select()
            .column("*").from("t1")
            .union({
                $0.column("*").from("t2")
            })
            .orderBy("id")
            .orderBy("name", .descending)
            .run()
            .wait()
        XCTAssertEqual(db.results[20], "(SELECT * FROM `t1`) UNION (SELECT * FROM `t2`) ORDER BY `id` ASC, `name` DESC")
    }
}
