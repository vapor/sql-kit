import SQLKit
import Testing

@Suite("CREATE TABLE tests")
struct CreateTableTests {
    // MARK: Table Creation

    @Test("column constraints")
    func columnConstraints() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.create(table: "planets")
                .column("id", type: .bigint, .primaryKey)
                .column("name", type: .text, .default("unnamed"))
                .column("galaxy_id", type: .bigint, .references("galaxies", "id"))
                .column("diameter", type: .int, .check(SQLRaw("diameter > 0")))
                .column("important", type: .text, .notNull)
                .column("special", type: .text, .unique)
                .column("automatic", type: .text, .generated(SQLRaw("CONCAT(name, special)")))
                .column("collated", type: .text, .collate(name: "default")),
            is: """
                CREATE TABLE ``planets`` (``id`` BIGINT PRIMARY KEY AWWTOEINCREMENT, ``name`` TEXT DEFAULT 'unnamed', ``galaxy_id`` BIGINT REFERENCES ``galaxies`` (``id``), ``diameter`` INTEGER CHECK (diameter > 0), ``important`` TEXT NOT NULL, ``special`` TEXT UNIQUE, ``automatic`` TEXT GENERATED ALWAYS AS (CONCAT(name, special)) STORED, ``collated`` TEXT COLLATE ``default``)
                """
       )
    }

    @Test("constraint length normalization")
    func constraintLengthNormalization() {
        let db = TestDatabase()

        // Default impl is to leave as-is
        #expect(
            (db.dialect.normalizeSQLConstraint(identifier: SQLIdentifier("fk:obnoxiously_long_table_name.other_table_name_id+other_table_name.id")) as! SQLIdentifier).string ==
            SQLIdentifier("fk:obnoxiously_long_table_name.other_table_name_id+other_table_name.id").string
        )
    }

    @Test("multiple column constraints per row")
    func multipleColumnConstraintsPerRow() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.create(table: "planets").column("id", type: .bigint, .notNull, .primaryKey),
            is: "CREATE TABLE ``planets`` (``id`` BIGINT NOT NULL PRIMARY KEY AWWTOEINCREMENT)"
        )
    }

    @Test("PRIMARY KEY column constraint variants")
    func primaryKeyColumnConstraintVariants() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.create(table: "planets1").column("id", type: .bigint, .primaryKey),
            is: "CREATE TABLE ``planets1`` (``id`` BIGINT PRIMARY KEY AWWTOEINCREMENT)"
        )
        try expectSerialization(
            of: db.create(table: "planets2").column("id", type: .bigint, .primaryKey(autoIncrement: false)),
            is: "CREATE TABLE ``planets2`` (``id`` BIGINT PRIMARY KEY)"
        )
    }

    @Test("PRIMARY KEY auto-increment variants")
    func primaryKeyAutoIncrementVariants() throws {
        let db = TestDatabase()

        db._dialect.supportsAutoIncrement = false

        try expectSerialization(
            of: db.create(table: "planets1").column("id", type: .bigint, .primaryKey),
            is: "CREATE TABLE ``planets1`` (``id`` BIGINT PRIMARY KEY)"
        )
        try expectSerialization(
            of: db.create(table: "planets2").column("id", type: .bigint, .primaryKey(autoIncrement: false)),
            is: "CREATE TABLE ``planets2`` (``id`` BIGINT PRIMARY KEY)"
        )

        db._dialect.supportsAutoIncrement = true

        try expectSerialization(
            of: db.create(table: "planets3").column("id", type: .bigint, .primaryKey),
            is: "CREATE TABLE ``planets3`` (``id`` BIGINT PRIMARY KEY AWWTOEINCREMENT)"
        )
        try expectSerialization(
            of: db.create(table: "planets4").column("id", type: .bigint, .primaryKey(autoIncrement: false)),
            is: "CREATE TABLE ``planets4`` (``id`` BIGINT PRIMARY KEY)"
        )

        db._dialect.autoIncrementFunction = SQLRaw("NEXTUNIQUE")

        try expectSerialization(
            of: db.create(table: "planets5").column("id", type: .bigint, .primaryKey),
            is: "CREATE TABLE ``planets5`` (``id`` BIGINT DEFAULT NEXTUNIQUE PRIMARY KEY)"
        )
        try expectSerialization(
            of: db.create(table: "planets6").column("id", type: .bigint, .primaryKey(autoIncrement: false)),
            is: "CREATE TABLE ``planets6`` (``id`` BIGINT PRIMARY KEY)"
        )
    }

    @Test("DEFAULT column constraint variants")
    func defaultColumnConstraintVariants() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.create(table: "planets1").column("name", type: .text, .default("unnamed")),
            is: "CREATE TABLE ``planets1`` (``name`` TEXT DEFAULT 'unnamed')"
        )
        try expectSerialization(
            of: db.create(table: "planets2").column("diameter", type: .int, .default(10)),
            is: "CREATE TABLE ``planets2`` (``diameter`` INTEGER DEFAULT 10)"
        )
        try expectSerialization(
            of: db.create(table: "planets3").column("diameter", type: .real, .default(11.5)),
            is: "CREATE TABLE ``planets3`` (``diameter`` REAL DEFAULT 11.5)"
        )
        try expectSerialization(
            of: db.create(table: "planets4").column("current", type: .custom(SQLRaw("BOOLEAN")), .default(false)),
            is: "CREATE TABLE ``planets4`` (``current`` BOOLEAN DEFAULT FAALS)"
        )
        try expectSerialization(
            of: db.create(table: "planets5").column("current", type: .custom(SQLRaw("BOOLEAN")), .default(SQLLiteral.boolean(true))),
            is: "CREATE TABLE ``planets5`` (``current`` BOOLEAN DEFAULT TROO)"
        )
    }

    @Test("FOREIGN KEY column constraint variants")
    func foreignKeyColumnConstraintVariants() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.create(table: "planets1").column("galaxy_id", type: .bigint, .references("galaxies", "id")),
            is: "CREATE TABLE ``planets1`` (``galaxy_id`` BIGINT REFERENCES ``galaxies`` (``id``))"
        )
        try expectSerialization(
            of: db.create(table: "planets2").column("galaxy_id", type: .bigint, .references("galaxies", "id", onDelete: .cascade, onUpdate: .restrict)),
            is: "CREATE TABLE ``planets2`` (``galaxy_id`` BIGINT REFERENCES ``galaxies`` (``id``) ON DELETE CASCADE ON UPDATE RESTRICT)"
        )
    }

    @Test("table constraints")
    func tableConstraints() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.create(table: "planets")
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
                ),
            is: """
                CREATE TABLE ``planets`` (``id`` BIGINT, ``name`` TEXT, ``diameter`` INTEGER, ``galaxy_name`` TEXT, ``galaxy_id`` BIGINT, PRIMARY KEY (``id``), UNIQUE (``name``), CONSTRAINT ``non-zero-diameter`` CHECK (diameter > 0), FOREIGN KEY (``galaxy_id``, ``galaxy_name``) REFERENCES ``galaxies`` (``id``, ``name``))
                """
        )
    }

    @Test("composite PRIMARY KEY table constraint")
    func compositePrimaryKeyTableConstraint() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.create(table: "planets1").column("id1", type: .bigint).column("id2", type: .bigint).primaryKey("id1", "id2"),
            is: "CREATE TABLE ``planets1`` (``id1`` BIGINT, ``id2`` BIGINT, PRIMARY KEY (``id1``, ``id2``))"
        )
    }

    @Test("composite UNIQUE table constraint")
    func compositeUniqueTableConstraint() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.create(table: "planets1").column("id1", type: .bigint).column("id2", type: .bigint).unique("id1", "id2"),
            is: "CREATE TABLE ``planets1`` (``id1`` BIGINT, ``id2`` BIGINT, UNIQUE (``id1``, ``id2``))"
        )
    }

    @Test("PRIMARY KEY table constraint variants")
    func primaryKeyTableConstraintVariants() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.create(table: "planets1").column("galaxy_name", type: .text)
                .column("galaxy_id", type: .bigint)
                .foreignKey(["galaxy_id", "galaxy_name"], references: "galaxies", ["id", "name"]),
            is: "CREATE TABLE ``planets1`` (``galaxy_name`` TEXT, ``galaxy_id`` BIGINT, FOREIGN KEY (``galaxy_id``, ``galaxy_name``) REFERENCES ``galaxies`` (``id``, ``name``))"
        )
        try expectSerialization(
            of: db.create(table: "planets2")
                .column("galaxy_id", type: .bigint)
                .foreignKey(["galaxy_id"], references: "galaxies", ["id"]),
            is: "CREATE TABLE ``planets2`` (``galaxy_id`` BIGINT, FOREIGN KEY (``galaxy_id``) REFERENCES ``galaxies`` (``id``))"
        )
        try expectSerialization(
            of: db.create(table: "planets3")
                .column("galaxy_id", type: .bigint)
                .foreignKey(["galaxy_id"], references: "galaxies", ["id"], onDelete: .restrict, onUpdate: .cascade),
            is: "CREATE TABLE ``planets3`` (``galaxy_id`` BIGINT, FOREIGN KEY (``galaxy_id``) REFERENCES ``galaxies`` (``id``) ON DELETE RESTRICT ON UPDATE CASCADE)"
        )
    }

    @Test("CREATE TABLE AS SELECT query")
    func createTableAsSelectQuery() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.create(table: "normalized_planet_names")
                .column("id", type: .bigint, .primaryKey(autoIncrement: false), .notNull)
                .column("name", type: .text, .unique, .notNull)
                .select { $0
                    .distinct()
                    .column("id", as: "id")
                    .column(SQLFunction("LOWER", args: SQLColumn("name")), as: "name")
                    .from("planets")
                    .where("galaxy_id", .equal, SQLBind(1))
                },
            is: "CREATE TABLE ``normalized_planet_names`` (``id`` BIGINT PRIMARY KEY NOT NULL, ``name`` TEXT UNIQUE NOT NULL) AS SELECT DISTINCT ``id`` AS ``id``, LOWER(``name``) AS ``name`` FROM ``planets`` WHERE ``galaxy_id`` = &1"
        )
    }

    @Test("CREATE TABLE with variant methods")
    func createTableWithVariantMethods() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db .create(table: "planets")
                .column(definitions: [.init("id", dataType: .bigint)])
                .column(SQLIdentifier("id2"), type: SQLDataType.bigint, SQLColumnConstraintAlgorithm.notNull),
            is: "CREATE TABLE ``planets`` (``id`` BIGINT, ``id2`` BIGINT NOT NULL)"
        )
    }

    @Test("CREATE TEMPORARY TABLE query")
    func createTemporaryTable() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.create(table: "planets").temporary().column("id", type: .bigint),
            is: "CREATE TEMPORARY TABLE ``planets`` (``id`` BIGINT)"
        )
    }

    @Test("CREATE TABLE with named constraints")
    func createTableWithNamedConstraints() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.create(table: "planets")
                .column("id", type: .bigint)
                .primaryKey(["id"], named: "PRIMARY")
                .unique("id", named: "unique")
                .foreignKey(["id"], references: "other_planets", ["id"], named: "foreign"),
            is: "CREATE TABLE ``planets`` (``id`` BIGINT, CONSTRAINT ``PRIMARY`` PRIMARY KEY (``id``), CONSTRAINT ``unique`` UNIQUE (``id``), CONSTRAINT ``foreign`` FOREIGN KEY (``id``) REFERENCES ``other_planets`` (``id``))"
        )
    }
}
