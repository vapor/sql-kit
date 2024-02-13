import SQLKit
import SQLKitBenchmark
import XCTest

final class SQLKitTests: XCTestCase {
    var db: TestDatabase!

    override class func setUp() {
        XCTAssert(isLoggingConfigured)
    }
    
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
    
    func testSelect_tableAllCols() {
        XCTAssertEqual(try self.db
            .select()
            .column(table: "planets", column: "*")
            .from("planets")
            .where("name", .equal, SQLBind("Earth"))
            .simpleSerialize(),
            "SELECT `planets`.* FROM `planets` WHERE `name` = ?"
        )
    }
    
    func testSelect_whereEncodable() {
        XCTAssertEqual(try self.db
            .select()
            .column("*")
            .from("planets")
            .where("name", .equal, "Earth")
            .orWhere("name", .equal, "Mars")
            .simpleSerialize(),
            "SELECT * FROM `planets` WHERE `name` = ? OR `name` = ?"
        )
    }
    
    func testSelect_whereList() {
        XCTAssertEqual(try self.db
            .select()
            .column("*")
            .from("planets")
            .where("name", .in, ["Earth", "Mars"])
            .orWhere("name", .in, ["Venus", "Mercury"])
            .simpleSerialize(),
            "SELECT * FROM `planets` WHERE `name` IN (?, ?) OR `name` IN (?, ?)"
        )
    }

    func testSelect_whereGroup() {
        XCTAssertEqual(try self.db
            .select()
            .column("*")
            .from("planets")
            .where { $0
                .where("name", .equal, "Earth")
                .orWhere("name", .equal, "Mars")
            }
            .where("color", .equal, "blue")
            .simpleSerialize(),
            "SELECT * FROM `planets` WHERE (`name` = ? OR `name` = ?) AND `color` = ?"
        )
    }
    
    func testSelect_whereColumn() {
        XCTAssertEqual(try self.db
            .select()
            .column("*")
            .from("planets")
            .where("name", .notEqual, column: "color")
            .orWhere("name", .equal, column: "greekName")
            .simpleSerialize(),
            "SELECT * FROM `planets` WHERE `name` <> `color` OR `name` = `greekName`"
        )
	}
	
    func testSelect_withoutFrom() {
        XCTAssertEqual(try self.db
            .select()
            .column(SQLAlias.init(SQLFunction("LAST_INSERT_ID"), as: SQLIdentifier.init("id")))
            .simpleSerialize(),
            "SELECT LAST_INSERT_ID() AS `id`"
        )
    }
    
    func testSelect_limitAndOrder() {
        XCTAssertEqual(try self.db
            .select()
            .column("*")
            .from("planets")
            .limit(3)
            .offset(5)
            .orderBy("name")
            .simpleSerialize(),
            "SELECT * FROM `planets` ORDER BY `name` ASC LIMIT 3 OFFSET 5"
        )
    }
    
    func testUpdate() {
        XCTAssertEqual(try self.db
            .update("planets")
            .where("name", .equal, "Jpuiter")
            .set("name", to: "Jupiter")
            .simpleSerialize(),
            "UPDATE `planets` SET `name` = ? WHERE `name` = ?"
        )
    }

    func testDelete() {
        XCTAssertEqual(try self.db
            .delete(from: "planets")
            .where("name", .equal, "Jupiter")
            .simpleSerialize(),
            "DELETE FROM `planets` WHERE `name` = ?"
        )
    }
    
    // MARK: Locking Clauses
    
    func testLockingClause_forUpdate() {
        XCTAssertEqual(try self.db
            .select()
            .column("*")
            .from("planets")
            .where("name", .equal, "Earth")
            .for(.update)
            .simpleSerialize(),
            "SELECT * FROM `planets` WHERE `name` = ? FOR UPDATE"
        )
    }
    
    func testLockingClause_forShare() {
        XCTAssertEqual(try self.db
            .select()
            .column("*")
            .from("planets")
            .where("name", .equal, "Earth")
            .for(.share)
            .simpleSerialize(),
            "SELECT * FROM `planets` WHERE `name` = ? FOR SHARE"
        )
    }
    
    func testLockingClause_raw() {
        XCTAssertEqual(try self.db
            .select()
            .column("*")
            .from("planets")
            .where("name", .equal, "Earth")
            .lockingClause(SQLRaw("LOCK IN SHARE MODE"))
            .simpleSerialize(),
            "SELECT * FROM `planets` WHERE `name` = ? LOCK IN SHARE MODE"
        )
    }
    
    // MARK: Group By/Having
    
    func testGroupByHaving() {
        XCTAssertEqual(try self.db
            .select()
            .column("*")
            .from("planets")
            .groupBy("color")
            .having("color", .equal, "blue")
            .simpleSerialize(),
            "SELECT * FROM `planets` GROUP BY `color` HAVING `color` = ?"
        )
    }
    
    // MARK: Dialect-Specific Behaviors

    func testIfExists() {
        self.db._dialect.supportsIfExists = true
        XCTAssertEqual(try self.db.drop(table: "planets").ifExists().simpleSerialize(), "DROP TABLE IF EXISTS `planets`")
        XCTAssertEqual(try self.db.drop(index: "planets_name_idx").ifExists().simpleSerialize(), "DROP INDEX IF EXISTS `planets_name_idx`")

        self.db._dialect.supportsIfExists = false
        XCTAssertEqual(try self.db.drop(table: "planets").ifExists().simpleSerialize(), "DROP TABLE `planets`")
        XCTAssertEqual(try self.db.drop(index: "planets_name_idx").ifExists().simpleSerialize(), "DROP INDEX `planets_name_idx`")
    }

    func testDropBehavior() {
        self.db._dialect.supportsDropBehavior = false
        XCTAssertEqual(try self.db.drop(table: "planets").simpleSerialize()                             , "DROP TABLE `planets`")
        XCTAssertEqual(try self.db.drop(index: "planets_name_idx").simpleSerialize()                    , "DROP INDEX `planets_name_idx`")
        XCTAssertEqual(try self.db.drop(table: "planets").behavior(.cascade).simpleSerialize()          , "DROP TABLE `planets`")
        XCTAssertEqual(try self.db.drop(index: "planets_name_idx").behavior(.cascade).simpleSerialize() , "DROP INDEX `planets_name_idx`")
        XCTAssertEqual(try self.db.drop(table: "planets").behavior(.restrict).simpleSerialize()         , "DROP TABLE `planets`")
        XCTAssertEqual(try self.db.drop(index: "planets_name_idx").behavior(.restrict).simpleSerialize(), "DROP INDEX `planets_name_idx`")
        XCTAssertEqual(try self.db.drop(table: "planets").cascade().simpleSerialize()                   , "DROP TABLE `planets`")
        XCTAssertEqual(try self.db.drop(index: "planets_name_idx").cascade().simpleSerialize()          , "DROP INDEX `planets_name_idx`")
        XCTAssertEqual(try self.db.drop(table: "planets").restrict().simpleSerialize()                  , "DROP TABLE `planets`")
        XCTAssertEqual(try self.db.drop(index: "planets_name_idx").restrict().simpleSerialize()         , "DROP INDEX `planets_name_idx`")

        self.db._dialect.supportsDropBehavior = true
        XCTAssertEqual(try self.db.drop(table: "planets").simpleSerialize()                             , "DROP TABLE `planets` RESTRICT")
        XCTAssertEqual(try self.db.drop(index: "planets_name_idx").simpleSerialize()                    , "DROP INDEX `planets_name_idx` RESTRICT")
        XCTAssertEqual(try self.db.drop(table: "planets").behavior(.cascade).simpleSerialize()          , "DROP TABLE `planets` CASCADE")
        XCTAssertEqual(try self.db.drop(index: "planets_name_idx").behavior(.cascade).simpleSerialize() , "DROP INDEX `planets_name_idx` CASCADE")
        XCTAssertEqual(try self.db.drop(table: "planets").behavior(.restrict).simpleSerialize()         , "DROP TABLE `planets` RESTRICT")
        XCTAssertEqual(try self.db.drop(index: "planets_name_idx").behavior(.restrict).simpleSerialize(), "DROP INDEX `planets_name_idx` RESTRICT")
        XCTAssertEqual(try self.db.drop(table: "planets").cascade().simpleSerialize()                   , "DROP TABLE `planets` CASCADE")
        XCTAssertEqual(try self.db.drop(index: "planets_name_idx").cascade().simpleSerialize()          , "DROP INDEX `planets_name_idx` CASCADE")
        XCTAssertEqual(try self.db.drop(table: "planets").restrict().simpleSerialize()                  , "DROP TABLE `planets` RESTRICT")
        XCTAssertEqual(try self.db.drop(index: "planets_name_idx").restrict().simpleSerialize()         , "DROP INDEX `planets_name_idx` RESTRICT")
    }
    
    func testDropTemporary() {
        XCTAssertEqual(try self.db.drop(table: "normalized_planet_names").temporary().simpleSerialize(), "DROP TEMPORARY TABLE `normalized_planet_names`")
    }
    
    func testOwnerObjectsForDropIndex() {
        XCTAssertEqual(try self.db
            .drop(index: "some_crummy_mysql_index")
            .on("some_darn_mysql_table")
            .simpleSerialize(),
            "DROP INDEX `some_crummy_mysql_index` ON `some_darn_mysql_table`"
        )
    }

    func testAltering() {
        // SINGLE
        XCTAssertEqual(try self.db
            .alter(table: "alterable")
            .column("hello", type: .text)
            .simpleSerialize(),
            "ALTER TABLE `alterable` ADD `hello` TEXT"
        )
        XCTAssertEqual(try self.db
            .alter(table: "alterable")
            .dropColumn("hello")
            .simpleSerialize(),
            "ALTER TABLE `alterable` DROP `hello`"
        )
        XCTAssertEqual(try self.db
            .alter(table: "alterable")
            .modifyColumn("hello", type: .text)
            .simpleSerialize(),
            "ALTER TABLE `alterable` MODIFY `hello` TEXT"
        )

        // BATCH
        XCTAssertEqual(try self.db
            .alter(table: "alterable")
            .column("hello", type: .text)
            .column("there", type: .text)
            .simpleSerialize(),
            "ALTER TABLE `alterable` ADD `hello` TEXT , ADD `there` TEXT"
        )
        XCTAssertEqual(try self.db
            .alter(table: "alterable")
            .dropColumn("hello")
            .dropColumn("there")
            .simpleSerialize(),
            "ALTER TABLE `alterable` DROP `hello` , DROP `there`"
        )
        XCTAssertEqual(try self.db
            .alter(table: "alterable")
            .update(column: "hello", type: .text)
            .update(column: "there", type: .text)
            .simpleSerialize(),
            "ALTER TABLE `alterable` MODIFY `hello` TEXT , MODIFY `there` TEXT"
        )

        // MIXED
        XCTAssertEqual(try self.db
            .alter(table: "alterable")
            .column("hello", type: .text)
            .dropColumn("there")
            .update(column: "again", type: .text)
            .simpleSerialize(),
            "ALTER TABLE `alterable` ADD `hello` TEXT , DROP `there` , MODIFY `again` TEXT"
        )

        // Table renaming
        XCTAssertEqual(try self.db
            .alter(table: "alterable")
            .rename(to: "new_alterable")
            .simpleSerialize(),
            "ALTER TABLE `alterable` RENAME TO `new_alterable`"
        )
    }
    
    // MARK: Distinct
    
    func testDistinct() {
        XCTAssertEqual(try self.db
            .select()
            .column("*")
            .from("planets")
            .groupBy("color")
            .having("color", .equal, "blue")
            .distinct()
            .simpleSerialize(),
            "SELECT DISTINCT * FROM `planets` GROUP BY `color` HAVING `color` = ?"
        )
    }
    
    func testDistinctColumns() {
        XCTAssertEqual(try self.db
            .select()
            .distinct(on: "name", "color")
            .from("planets")
            .simpleSerialize(),
            "SELECT DISTINCT `name`, `color` FROM `planets`"
        )
    }
    
    func testDistinctExpression() {
        XCTAssertEqual(try self.db
            .select()
            .column(SQLFunction("COUNT", args: SQLDistinct("name", "color")))
            .from("planets")
            .simpleSerialize(),
            "SELECT COUNT(DISTINCT(`name`, `color`)) FROM `planets`"
        )
    }
    
    // MARK: Joins
    
    func testSimpleJoin() {
        XCTAssertEqual(try self.db
            .select()
            .column("*")
            .from("planets")
            .join("moons", on: "\(ident: "moons").\(ident: "planet_id")=\(ident: "planets").\(ident: "id")" as SQLQueryString)
            .simpleSerialize(),
            "SELECT * FROM `planets` INNER JOIN `moons` ON `moons`.`planet_id`=`planets`.`id`"
        )
    }
    
    func testMessyJoin() {
        XCTAssertEqual(try self.db
            .select()
            .column("*")
            .from("planets")
            .join(
                SQLAlias(SQLGroupExpression(
                    self.db.select().column("name").from("stars").where(SQLColumn("orion"), .equal, SQLIdentifier("please space")).select
                ), as: SQLIdentifier("star")),
                method: SQLJoinMethod.outer,
                on: SQLColumn(SQLIdentifier("planet_id"), table: SQLIdentifier("moons")), SQLBinaryOperator.isNot, SQLRaw("%%%%%%")
            )
            .where(SQLLiteral.null)
            .simpleSerialize(),
            // Yes, this query is very much pure gibberish.
            "SELECT * FROM `planets` OUTER JOIN (SELECT `name` FROM `stars` WHERE `orion` = `please space`) AS `star` ON `moons`.`planet_id` IS NOT %%%%%% WHERE NULL"
        )
    }
    
    // MARK: Operators
    
    func testBinaryOperators() {
        XCTAssertEqual(try self.db
            .update("planets")
            .set(SQLIdentifier("moons"),
                 to: SQLBinaryExpression(
                    left: SQLIdentifier("moons"),
                    op: SQLBinaryOperator.add,
                    right: SQLLiteral.numeric("1")
                )
            )
            .where("best_at_space", .greaterThanOrEqual, "yes")
            .simpleSerialize(),
            "UPDATE `planets` SET `moons` = `moons` + 1 WHERE `best_at_space` >= ?"
        )
    }
    
    func testInsertWithArrayOfEncodable() {
        func weird<S: Sequence>(_ builder: SQLInsertBuilder, values: S) -> SQLInsertBuilder where S.Element: Encodable {
            builder.values(Array(values))
        }
        
        let output = XCTAssertNoThrowWithResult(try weird(
                self.db.insert(into: "planets").columns("name"),
                values: ["Jupiter"]
            )
            .advancedSerialize()
        )
        XCTAssertEqual(output?.sql, "INSERT INTO `planets` (`name`) VALUES (?)")
        XCTAssertEqual(output?.binds as? [String], ["Jupiter"]) // instead of [["Jupiter"]]
    }

    // MARK: Returning

    func testReturning() {
        XCTAssertEqual(try self.db
            .insert(into: "planets")
            .columns("name")
            .values("Jupiter")
            .returning("id", "name")
            .simpleSerialize(),
            "INSERT INTO `planets` (`name`) VALUES (?) RETURNING `id`, `name`"
        )

        XCTAssertEqual(try self.db
            .update("planets")
            .set("name", to: "Jupiter")
            .returning(SQLColumn("name", table: "planets"))
            .simpleSerialize(),
            "UPDATE `planets` SET `name` = ? RETURNING `planets`.`name`"
        )

        XCTAssertEqual(try self.db
            .delete(from: "planets")
            .returning("*")
            .simpleSerialize(),
            "DELETE FROM `planets` RETURNING *"
        )
    }
    
    // MARK: Upsert
    
    func testUpsert() {
        // Test the thoroughly underpowered and inconvenient MySQL syntax first
        db._dialect.upsertSyntax = .mysqlLike
        
        let cols = ["id", "serial_number", "star_id", "last_known_status"]
        let vals = { (s: String) -> [any SQLExpression] in [SQLLiteral.default, SQLBind(UUID()), SQLBind(1), SQLBind(s)] }
        
        XCTAssertEqual(
            try self.db.insert(into: "jumpgates").columns(cols).values(vals("calibration")).simpleSerialize(),
            "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?)"
        )
        XCTAssertEqual(
            try self.db.insert(into: "jumpgates").columns(cols).values(vals("unicorn dust application")).ignoringConflicts().simpleSerialize(),
            "INSERT IGNORE INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?)"
        )
        XCTAssertEqual(
            try self.db.insert(into: "jumpgates").columns(cols).values(vals("planet-size snake oil jar purchasing"))
            .onConflict() { $0
                .set("last_known_status", to: "Hooloovoo engineer refraction")
                .set(excludedValueOf: "serial_number")
            }
            .simpleSerialize(),
            "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?) ON DUPLICATE KEY UPDATE `last_known_status` = ?, `serial_number` = VALUES(`serial_number`)"
        )
        
        // Now the standard SQL syntax
        db._dialect.upsertSyntax = .standard
        
        XCTAssertEqual(
            try self.db.insert(into: "jumpgates").columns(cols).values(vals("calibration")).simpleSerialize(),
            "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?)"
        )
        
        XCTAssertEqual(
            try self.db.insert(into: "jumpgates").columns(cols).values(vals("unicorn dust application")).ignoringConflicts().simpleSerialize(),
            "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?) ON CONFLICT DO NOTHING"
        )
        XCTAssertEqual(
            try self.db
                .insert(into: "jumpgates").columns(cols).values(vals("Vorlon pinching"))
                .ignoringConflicts(with: ["serial_number", "star_id"])
                .simpleSerialize(),
            "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?) ON CONFLICT (`serial_number`, `star_id`) DO NOTHING"
        )
        XCTAssertEqual(
            try self.db
                .insert(into: "jumpgates").columns(cols).values(vals("planet-size snake oil jar purchasing"))
                .onConflict() { $0
                    .set("last_known_status", to: "Hooloovoo engineer refraction").set(excludedValueOf: "serial_number")
                }
                .simpleSerialize(),
            "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?) ON CONFLICT DO UPDATE SET `last_known_status` = ?, `serial_number` = EXCLUDED.`serial_number`"
        )
        XCTAssertEqual(
            try self.db
                .insert(into: "jumpgates").columns(cols).values(vals("slashfic writing"))
                .onConflict(with: ["serial_number"]) { $0
                    .set("last_known_status", to: "tachyon antitelephone dialing the").set(excludedValueOf: "star_id")
                }
                .simpleSerialize(),
            "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?) ON CONFLICT (`serial_number`) DO UPDATE SET `last_known_status` = ?, `star_id` = EXCLUDED.`star_id`"
        )
        XCTAssertEqual(
            try self.db
                .insert(into: "jumpgates").columns(cols).values(vals("protection racket payoff"))
                .onConflict(with: ["id"]) { $0
                    .set("last_known_status", to: "insurance fraud planning")
                    .where("last_known_status", .notEqual, "evidence disposal")
                }
                .simpleSerialize(),
            "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?) ON CONFLICT (`id`) DO UPDATE SET `last_known_status` = ? WHERE `last_known_status` <> ?"
        )
    }
    
    // MARK: Table Creation

    func testColumnConstraints() {
        XCTAssertEqual(try self.db
            .create(table: "planets")
            .column("id", type: .bigint, .primaryKey)
            .column("name", type: .text, .default("unnamed"))
            .column("galaxy_id", type: .bigint, .references("galaxies", "id"))
            .column("diameter", type: .int, .check(SQLRaw("diameter > 0")))
            .column("important", type: .text, .notNull)
            .column("special", type: .text, .unique)
            .column("automatic", type: .text, .generated(SQLRaw("CONCAT(name, special)")))
            .column("collated", type: .text, .collate(name: "default"))
            .simpleSerialize(),
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

    func testMultipleColumnConstraintsPerRow() {
        XCTAssertEqual(try self.db
            .create(table: "planets")
            .column("id", type: .bigint, .notNull, .primaryKey)
            .simpleSerialize(),
            "CREATE TABLE `planets`(`id` BIGINT NOT NULL PRIMARY KEY AUTOINCREMENT)"
        )
    }

    func testPrimaryKeyColumnConstraintVariants() {
        XCTAssertEqual(try self.db
            .create(table: "planets1")
            .column("id", type: .bigint, .primaryKey)
            .simpleSerialize(),
            "CREATE TABLE `planets1`(`id` BIGINT PRIMARY KEY AUTOINCREMENT)"
        )
        XCTAssertEqual(try self.db
            .create(table: "planets2")
            .column("id", type: .bigint, .primaryKey(autoIncrement: false))
            .simpleSerialize(),
            "CREATE TABLE `planets2`(`id` BIGINT PRIMARY KEY)"
        )
    }

    func testPrimaryKeyAutoIncrementVariants() {
        self.db._dialect.supportsAutoIncrement = false

        XCTAssertEqual(try self.db
            .create(table: "planets1")
            .column("id", type: .bigint, .primaryKey)
            .simpleSerialize(),
            "CREATE TABLE `planets1`(`id` BIGINT PRIMARY KEY)"
        )
        XCTAssertEqual(try self.db
            .create(table: "planets2")
            .column("id", type: .bigint, .primaryKey(autoIncrement: false))
            .simpleSerialize(),
            "CREATE TABLE `planets2`(`id` BIGINT PRIMARY KEY)"
        )

        self.db._dialect.supportsAutoIncrement = true

        XCTAssertEqual(try self.db
            .create(table: "planets3")
            .column("id", type: .bigint, .primaryKey)
            .simpleSerialize(),
            "CREATE TABLE `planets3`(`id` BIGINT PRIMARY KEY AUTOINCREMENT)"
        )
        XCTAssertEqual(try self.db
            .create(table: "planets4")
            .column("id", type: .bigint, .primaryKey(autoIncrement: false))
            .simpleSerialize(),
            "CREATE TABLE `planets4`(`id` BIGINT PRIMARY KEY)"
        )
        
        self.db._dialect.supportsAutoIncrement = true
        self.db._dialect.autoIncrementFunction = SQLRaw("NEXTUNIQUE")

        XCTAssertEqual(try self.db
            .create(table: "planets5")
            .column("id", type: .bigint, .primaryKey)
            .simpleSerialize(),
            "CREATE TABLE `planets5`(`id` BIGINT DEFAULT NEXTUNIQUE PRIMARY KEY)"
        )
        XCTAssertEqual(try self.db
            .create(table: "planets6")
            .column("id", type: .bigint, .primaryKey(autoIncrement: false))
            .simpleSerialize(),
            "CREATE TABLE `planets6`(`id` BIGINT PRIMARY KEY)"
        )
    }

    func testDefaultColumnConstraintVariants() {
        XCTAssertEqual(try self.db
            .create(table: "planets1")
            .column("name", type: .text, .default("unnamed"))
            .simpleSerialize(),
            "CREATE TABLE `planets1`(`name` TEXT DEFAULT 'unnamed')"
        )
        XCTAssertEqual(try self.db
            .create(table: "planets2")
            .column("diameter", type: .int, .default(10))
            .simpleSerialize(),
            "CREATE TABLE `planets2`(`diameter` INTEGER DEFAULT 10)"
        )
        XCTAssertEqual(try self.db
            .create(table: "planets3")
            .column("diameter", type: .real, .default(11.5))
            .simpleSerialize(),
            "CREATE TABLE `planets3`(`diameter` REAL DEFAULT 11.5)"
        )
        XCTAssertEqual(try self.db
            .create(table: "planets4")
            .column("current", type: .custom(SQLRaw("BOOLEAN")), .default(false))
            .simpleSerialize(),
            "CREATE TABLE `planets4`(`current` BOOLEAN DEFAULT false)"
        )
        XCTAssertEqual(try self.db
            .create(table: "planets5")
            .column("current", type: .custom(SQLRaw("BOOLEAN")), .default(SQLLiteral.boolean(true)))
            .simpleSerialize(),
            "CREATE TABLE `planets5`(`current` BOOLEAN DEFAULT true)"
        )
    }

    func testForeignKeyColumnConstraintVariants() {
        XCTAssertEqual(try self.db
            .create(table: "planets1")
            .column("galaxy_id", type: .bigint, .references("galaxies", "id"))
            .simpleSerialize(),
            "CREATE TABLE `planets1`(`galaxy_id` BIGINT REFERENCES `galaxies` (`id`))"
        )
        XCTAssertEqual(try self.db
            .create(table: "planets2")
            .column("galaxy_id", type: .bigint, .references("galaxies", "id", onDelete: .cascade, onUpdate: .restrict))
            .simpleSerialize(),
            "CREATE TABLE `planets2`(`galaxy_id` BIGINT REFERENCES `galaxies` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT)"
        )
    }

    func testTableConstraints() {
        XCTAssertEqual(try self.db
            .create(table: "planets")
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
            )
            .simpleSerialize(),
            """
            CREATE TABLE `planets`(`id` BIGINT, `name` TEXT, `diameter` INTEGER, `galaxy_name` TEXT, `galaxy_id` BIGINT, PRIMARY KEY (`id`), UNIQUE (`name`), CONSTRAINT `non-zero-diameter` CHECK (diameter > 0), FOREIGN KEY (`galaxy_id`, `galaxy_name`) REFERENCES `galaxies` (`id`, `name`))
            """
        )
    }

    func testCompositePrimaryKeyTableConstraint() {
        XCTAssertEqual(try self.db
            .create(table: "planets1")
            .column("id1", type: .bigint)
            .column("id2", type: .bigint)
            .primaryKey("id1", "id2")
            .simpleSerialize(),
            "CREATE TABLE `planets1`(`id1` BIGINT, `id2` BIGINT, PRIMARY KEY (`id1`, `id2`))"
        )
    }

    func testCompositeUniqueTableConstraint() {
        XCTAssertEqual(try self.db
            .create(table: "planets1")
            .column("id1", type: .bigint)
            .column("id2", type: .bigint)
            .unique("id1", "id2")
            .simpleSerialize(),
            "CREATE TABLE `planets1`(`id1` BIGINT, `id2` BIGINT, UNIQUE (`id1`, `id2`))"
        )
    }

    func testPrimaryKeyTableConstraintVariants() {
        XCTAssertEqual(try self.db
            .create(table: "planets1")
            .column("galaxy_name", type: .text)
            .column("galaxy_id", type: .bigint)
            .foreignKey(
                ["galaxy_id", "galaxy_name"],
                references: "galaxies",
                ["id", "name"]
            )
            .simpleSerialize(),
            "CREATE TABLE `planets1`(`galaxy_name` TEXT, `galaxy_id` BIGINT, FOREIGN KEY (`galaxy_id`, `galaxy_name`) REFERENCES `galaxies` (`id`, `name`))"
        )
        XCTAssertEqual(try self.db
            .create(table: "planets2")
            .column("galaxy_id", type: .bigint)
            .foreignKey(
                ["galaxy_id"],
                references: "galaxies",
                ["id"]
            )
            .simpleSerialize(),
            "CREATE TABLE `planets2`(`galaxy_id` BIGINT, FOREIGN KEY (`galaxy_id`) REFERENCES `galaxies` (`id`))"
        )
        XCTAssertEqual(try self.db
            .create(table: "planets3")
            .column("galaxy_id", type: .bigint)
            .foreignKey(
                ["galaxy_id"],
                references: "galaxies",
                ["id"],
                onDelete: .restrict,
                onUpdate: .cascade
            )
            .simpleSerialize(),
            "CREATE TABLE `planets3`(`galaxy_id` BIGINT, FOREIGN KEY (`galaxy_id`) REFERENCES `galaxies` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE)"
        )
    }
    
    func testCreateTableAsSelectQuery() {
        XCTAssertEqual(try self.db
            .create(table: "normalized_planet_names")
            .column("id", type: .bigint, .primaryKey(autoIncrement: false), .notNull)
            .column("name", type: .text, .unique, .notNull)
            .select { $0
                .distinct()
                .column("id", as: "id")
                .column(SQLFunction("LOWER", args: SQLColumn("name")), as: "name")
                .from("planets")
                .where("galaxy_id", .equal, SQLBind(1))
            }
            .simpleSerialize(),
            "CREATE TABLE `normalized_planet_names`(`id` BIGINT PRIMARY KEY NOT NULL, `name` TEXT UNIQUE NOT NULL) AS SELECT DISTINCT `id` AS `id`, LOWER(`name`) AS `name` FROM `planets` WHERE `galaxy_id` = ?"
        )
    }

    // MARK: Unions

    func testUnions() {
        // Check that queries are explicitly malformed without the feature flags
        self.db._dialect.unionFeatures = []
        XCTAssertEqual(try self.db
            .select()
            .column("id").from("t1").union(distinct: { $0.column("id").from("t2") })
            .simpleSerialize(),
            "SELECT `id` FROM `t1`  SELECT `id` FROM `t2`"
        )
        XCTAssertEqual(try self.db
            .select()
            .column("id").from("t1").union(all: { $0.column("id").from("t2") })
            .simpleSerialize(),
            "SELECT `id` FROM `t1`  SELECT `id` FROM `t2`"
        )
        XCTAssertEqual(try self.db
            .select()
            .column("id").from("t1").intersect(distinct: { $0.column("id").from("t2") })
            .simpleSerialize(),
            "SELECT `id` FROM `t1`  SELECT `id` FROM `t2`"
        )
        XCTAssertEqual(try self.db
            .select()
            .column("id").from("t1").intersect(all: { $0.column("id").from("t2") })
            .simpleSerialize(),
            "SELECT `id` FROM `t1`  SELECT `id` FROM `t2`"
        )
        XCTAssertEqual(try self.db
            .select()
            .column("id").from("t1").except(distinct: { $0.column("id").from("t2") })
            .simpleSerialize(),
            "SELECT `id` FROM `t1`  SELECT `id` FROM `t2`"
        )
        XCTAssertEqual(try self.db
            .select()
            .column("id").from("t1").except(all: { $0.column("id").from("t2") })
            .simpleSerialize(),
            "SELECT `id` FROM `t1`  SELECT `id` FROM `t2`"
        )

        // Test that queries are correctly formed with the feature flags
        self.db._dialect.unionFeatures.formUnion([.union, .unionAll, .intersect, .intersectAll, .except, .exceptAll])
        XCTAssertEqual(try self.db
            .select()
            .column("id").from("t1").union(distinct: { $0.column("id").from("t2") })
            .simpleSerialize(),
            "SELECT `id` FROM `t1` UNION SELECT `id` FROM `t2`"
        )
        XCTAssertEqual(try self.db
            .select()
            .column("id").from("t1").union(all: { $0.column("id").from("t2") })
            .simpleSerialize(),
            "SELECT `id` FROM `t1` UNION ALL SELECT `id` FROM `t2`"
        )
        XCTAssertEqual(try self.db
            .select()
            .column("id").from("t1").intersect(distinct: { $0.column("id").from("t2") })
            .simpleSerialize(),
            "SELECT `id` FROM `t1` INTERSECT SELECT `id` FROM `t2`"
        )
        XCTAssertEqual(try self.db
            .select()
            .column("id").from("t1").intersect(all: { $0.column("id").from("t2") })
            .simpleSerialize(),
            "SELECT `id` FROM `t1` INTERSECT ALL SELECT `id` FROM `t2`"
        )
        XCTAssertEqual(try self.db
            .select()
            .column("id").from("t1").except(distinct: { $0.column("id").from("t2") })
            .simpleSerialize(),
            "SELECT `id` FROM `t1` EXCEPT SELECT `id` FROM `t2`"
        )
        XCTAssertEqual(try self.db
            .select()
            .column("id").from("t1").except(all: { $0.column("id").from("t2") })
            .simpleSerialize(),
            "SELECT `id` FROM `t1` EXCEPT ALL SELECT `id` FROM `t2`"
        )
        
        // Test that the explicit distinct flag is respected
        self.db._dialect.unionFeatures.insert(.explicitDistinct)
        XCTAssertEqual(try self.db
            .select()
            .column("id").from("t1").union(distinct: { $0.column("id").from("t2") })
            .simpleSerialize(),
            "SELECT `id` FROM `t1` UNION DISTINCT SELECT `id` FROM `t2`"
        )
        XCTAssertEqual(try self.db
            .select()
            .column("id").from("t1").intersect(distinct: { $0.column("id").from("t2") })
            .simpleSerialize(),
            "SELECT `id` FROM `t1` INTERSECT DISTINCT SELECT `id` FROM `t2`"
        )
        XCTAssertEqual(try self.db
            .select()
            .column("id").from("t1").except(distinct: { $0.column("id").from("t2") })
            .simpleSerialize(),
            "SELECT `id` FROM `t1` EXCEPT DISTINCT SELECT `id` FROM `t2`"
        )

        // Test that the parenthesized subqueries flag does as expected, including for multiple unions
        self.db._dialect.unionFeatures.formSymmetricDifference([.explicitDistinct, .parenthesizedSubqueries])
        XCTAssertEqual(try self.db
            .select()
            .column("id").from("t1").union(distinct: { $0.column("id").from("t2") })
            .simpleSerialize(),
            "(SELECT `id` FROM `t1`) UNION (SELECT `id` FROM `t2`)"
        )
        XCTAssertEqual(try self.db
            .select()
            .column("id")
            .from("t1")
                .union(distinct: { $0.column("id").from("t2") })
                .union(distinct: { $0.column("id").from("t3") })
            .simpleSerialize(),
            "(SELECT `id` FROM `t1`) UNION (SELECT `id` FROM `t2`) UNION (SELECT `id` FROM `t3`)"
        )

        // Test that chaining and mixing multiple union types works
        self.db._dialect.unionFeatures.insert(.explicitDistinct)
        XCTAssertEqual(try self.db
            .select()
            .column("id").from("t1")
              .union(distinct:     { $0.column("id").from("t2") })
              .union(all:          { $0.column("id").from("t3") })
              .intersect(distinct: { $0.column("id").from("t4") })
              .intersect(all:      { $0.column("id").from("t5") })
              .except(distinct:    { $0.column("id").from("t6") })
              .except(all:         { $0.column("id").from("t7") })
            .simpleSerialize(),
            "(SELECT `id` FROM `t1`) UNION DISTINCT (SELECT `id` FROM `t2`) UNION ALL (SELECT `id` FROM `t3`) INTERSECT DISTINCT (SELECT `id` FROM `t4`) INTERSECT ALL (SELECT `id` FROM `t5`) EXCEPT DISTINCT (SELECT `id` FROM `t6`) EXCEPT ALL (SELECT `id` FROM `t7`)"
        )
        
        // Test that having a single entry in the union just executes that entry
        XCTAssertEqual(try self.db
            .union { select in
                select.column("id").from("t1")
            }
            .simpleSerialize(),
            "SELECT `id` FROM `t1`"
        )

        // Test LIMIT, OFFSET, and ORDERBY
        self.db._dialect.unionFeatures.remove(.explicitDistinct)
        XCTAssertEqual(try self.db
            .select()
            .column("id").from("t1")
            .union({
                $0.column("id").from("t2")
            })
            .limit(3)
            .offset(5)
            .orderBy("id")
            .simpleSerialize(),
            "(SELECT `id` FROM `t1`) UNION (SELECT `id` FROM `t2`) ORDER BY `id` ASC LIMIT 3 OFFSET 5"
        )
        
        // Test multiple ORDERBY statements
        self.db._dialect.unionFeatures.remove(.explicitDistinct)
        XCTAssertEqual(try self.db
            .select()
            .column("*").from("t1")
            .union({
                $0.column("*").from("t2")
            })
            .orderBy("id")
            .orderBy("name", .descending)
            .simpleSerialize(),
            "(SELECT * FROM `t1`) UNION (SELECT * FROM `t2`) ORDER BY `id` ASC, `name` DESC"
        )
    }
    
    // MARK: JSON paths

    func testJSONPaths() {
        XCTAssertEqual(try self.db
            .select()
            .column(SQLNestedSubpathExpression(column: "json", path: ["a"]))
            .column(SQLNestedSubpathExpression(column: "json", path: ["a", "b"]))
            .column(SQLNestedSubpathExpression(column: "json", path: ["a", "b", "c"]))
            .column(SQLNestedSubpathExpression(column: SQLColumn("json", table: "table"), path: ["a", "b"]))
            .simpleSerialize(),
            "SELECT (`json`->>'a'), (`json`->'a'->>'b'), (`json`->'a'->'b'->>'c'), (`table`.`json`->'a'->>'b')"
        )
    }
}