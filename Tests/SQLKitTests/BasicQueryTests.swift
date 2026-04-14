import SQLKit
import Testing

@Suite("Basic query tests")
struct BasicQueryTests {
    // MARK: Select
    
    @Test("SELECT unqualified columns")
    func selectUnqualifiedColumns() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select()
                .column("*")
                .column("name")
                .column(SQLLiteral.all)
                .column(SQLIdentifier("name"))
                .columns("*")
                .columns("name")
                .columns(["*"])
                .columns(["name"])
                .columns(SQLLiteral.all)
                .columns(SQLIdentifier("name"))
                .columns([SQLLiteral.all])
                .columns([SQLIdentifier("name")]),
            is: "SELECT *, ``name``, *, ``name``, *, ``name``, *, ``name``, *, ``name``, *, ``name``"
        )
    }
    
    @Test("SELECT column aliasing")
    func selectColumnAliasing() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select()
                .column("name", as: "n")
                .column(SQLIdentifier("name"), as: "n")
                .column(SQLIdentifier("name"), as: SQLIdentifier("n"))
                .column(SQLAlias("name", as: "n"))
                .column(SQLAlias(SQLIdentifier("name"), as: "n"))
                .column(SQLAlias(SQLIdentifier("name"), as: SQLIdentifier("n"))),
            is: "SELECT ``name`` AS ``n``, ``name`` AS ``n``, ``name`` AS ``n``, ``name`` AS ``n``, ``name`` AS ``n``, ``name`` AS ``n``"
        )
    }
    
    @Test("SELECT FROM aliasing")
    func selectFROMAliasing() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select()
                .from("planets", as: "p"),
            is: "SELECT FROM ``planets`` AS ``p``"
        )
        try expectSerialization(
            of: db.select()
                .from(SQLIdentifier("planets"), as: SQLIdentifier("p")),
            is: "SELECT FROM ``planets`` AS ``p``"
        )
    }
    
    @Test("SELECT all table columns")
    func selectAllTableColumns() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select().columns(["*"]).from("planets").where("name", .equal, SQLBind("Earth")),
            is: "SELECT * FROM ``planets`` WHERE ``name`` = &1"
        )
        try expectSerialization(
            of: db.select().column(SQLColumn(SQLLiteral.all, table: SQLIdentifier("planets"))).from("planets").where("name", .equal, SQLBind("Earth")),
            is: "SELECT ``planets``.* FROM ``planets`` WHERE ``name`` = &1"
        )
    }
    
    @Test("SELECT WHERE Encodable")
    func selectWHEREEncodable() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select().column("*").from("planets").where("name", .equal, "Earth").orWhere("name", .equal, "Mars"),
            is: "SELECT * FROM ``planets`` WHERE ``name`` = &1 OR ``name`` = &2"
        )
    }
    
    @Test("SELECT WHERE array Encodable with string")
    func selectWHEREArrayEncodableWithString() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select().column("*").from("planets").where("name", .in, ["Earth", "Mars"]).orWhere("name", .in, ["Venus", "Mercury"]),
            is: "SELECT * FROM ``planets`` WHERE ``name`` IN (&1, &2) OR ``name`` IN (&3, &4)"
        )
    }

    @Test("SELECT WHERE array Encodable with identifier")
    func selectWHEREArrayEncodableWithIdentifier() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select().column("*").from("planets").where(SQLIdentifier("name"), .in, ["Earth", "Mars"]).orWhere(SQLIdentifier("name"), .in, ["Venus", "Mercury"]),
            is: "SELECT * FROM ``planets`` WHERE ``name`` IN (&1, &2) OR ``name`` IN (&3, &4)"
        )
    }

    @Test("SELECT WHERE group")
    func selectWHEREGroup() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select().column("*").from("planets")
                .where { $0.where("name", .equal, "Earth").orWhere("name", .equal, "Mars") }
                .orWhere { $0.where("color", .notEqual, "yellow") }
                .where("color", .equal, "blue"),
            is: "SELECT * FROM ``planets`` WHERE (``name`` = &1 OR ``name`` = &2) OR (``color`` <> &3) AND ``color`` = &4"
        )
    }
    
    @Test("SELECT WHERE empty group")
    func selectWHEREEmptyGroup() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select().column("*").from("planets").where { $0 }.orWhere { $0 }.where("color", .equal, "blue"),
            is: "SELECT * FROM ``planets`` WHERE ``color`` = &1"
        )
    }
    
    
    @Test("SELECT WHERE column")
    func selectWHEREColumn() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select().column("*").from("planets").where("name", .notEqual, column: "color").orWhere("name", .equal, column: "greekName"),
            is: "SELECT * FROM ``planets`` WHERE ``name`` <> ``color`` OR ``name`` = ``greekName``"
        )
	}

    @Test("SELECT other WHEREs")
    func selectOtherWHEREs() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select()
                .column("*")
                .from("planets")
                .where("name", .notEqual, SQLBind("color"))
                .orWhere("name", .notEqual, SQLBind("color")),
            is: "SELECT * FROM ``planets`` WHERE ``name`` <> &1 OR ``name`` <> &2"
        )
        try expectSerialization(
            of: db.select()
                .column("*")
                .from("planets")
                .where(SQLIdentifier("name"), .notEqual, column: SQLIdentifier("color"))
                .orWhere(SQLIdentifier("name"), .equal, column: SQLIdentifier("greekName")),
            is: "SELECT * FROM ``planets`` WHERE ``name`` <> ``color`` OR ``name`` = ``greekName``"
        )
        try expectSerialization(
            of: db.select()
                .column("*")
                .from("planets")
                .where(SQLIdentifier("name"), .notEqual, "color")
                .orWhere(SQLIdentifier("name"), .equal, "greekName"),
            is: "SELECT * FROM ``planets`` WHERE ``name`` <> &1 OR ``name`` = &2"
        )
        try expectSerialization(
            of: db.select()
                .column("*")
                .from("planets")
                .where(SQLIdentifier("name"), .notEqual, SQLBind("color"))
                .orWhere(SQLIdentifier("name"), .equal, SQLBind("greekName")),
            is: "SELECT * FROM ``planets`` WHERE ``name`` <> &1 OR ``name`` = &2"
        )
        try expectSerialization(
            of: db.select()
                .column("*")
                .from("planets")
                .orWhere(SQLIdentifier("name"), .equal, SQLBind("greekName")),
            is: "SELECT * FROM ``planets`` WHERE ``name`` = &1"
        )
	}

    @Test("SELECT HAVING Encodable")
    func selectHAVINGEncodable() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select().column("*").from("planets").having("name", .equal, "Earth").orHaving("name", .equal, "Mars"),
            is: "SELECT * FROM ``planets`` HAVING ``name`` = &1 OR ``name`` = &2"
        )
    }
    
    @Test("SELECT HAVING array Encodable with string")
    func selectHAVINGArrayEncodableWithString() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select().column("*").from("planets").having("name", .in, ["Earth", "Mars"]).orHaving("name", .in, ["Venus", "Mercury"]),
            is: "SELECT * FROM ``planets`` HAVING ``name`` IN (&1, &2) OR ``name`` IN (&3, &4)"
        )
    }

    @Test("SELECT HAVING array Encodable with identifier")
    func selectHAVINGArrayEncodableWithIdentifier() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select().column("*").from("planets").having(SQLIdentifier("name"), .in, ["Earth", "Mars"]).orHaving(SQLIdentifier("name"), .in, ["Venus", "Mercury"]),
            is: "SELECT * FROM ``planets`` HAVING ``name`` IN (&1, &2) OR ``name`` IN (&3, &4)"
        )
    }

    @Test("SELECT HAVING group")
    func selectHAVINGGroup() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select().column("*").from("planets")
                .having { $0.having("name", .equal, "Earth").orHaving("name", .equal, "Mars") }
                .orHaving { $0.having("color", .notEqual, "yellow") }
                .having("color", .equal, "blue"),
            is: "SELECT * FROM ``planets`` HAVING (``name`` = &1 OR ``name`` = &2) OR (``color`` <> &3) AND ``color`` = &4"
        )
    }
    
    @Test("SELECT HAVING empty group")
    func selectHAVINGEmptyGroup() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select().column("*").from("planets").having { $0 }.orHaving { $0 }.having("color", .equal, "blue"),
            is: "SELECT * FROM ``planets`` HAVING ``color`` = &1"
        )
    }
    
    
    @Test("SELECT HAVING column")
    func selectHAVINGColumn() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select().column("*").from("planets").having("name", .notEqual, column: "color").orHaving("name", .equal, column: "greekName"),
            is: "SELECT * FROM ``planets`` HAVING ``name`` <> ``color`` OR ``name`` = ``greekName``"
        )
	}

    @Test("SELECT other HAVINGs")
    func selectOtherHAVINGs() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select()
                .column("*")
                .from("planets")
                .having("name", .notEqual, SQLBind("color"))
                .orHaving("name", .notEqual, SQLBind("color")),
            is: "SELECT * FROM ``planets`` HAVING ``name`` <> &1 OR ``name`` <> &2"
        )
        try expectSerialization(
            of: db.select()
                .column("*")
                .from("planets")
                .having(SQLIdentifier("name"), .notEqual, column: SQLIdentifier("color"))
                .orHaving(SQLIdentifier("name"), .equal, column: SQLIdentifier("greekName")),
            is: "SELECT * FROM ``planets`` HAVING ``name`` <> ``color`` OR ``name`` = ``greekName``"
        )
        try expectSerialization(
            of: db.select()
                .column("*")
                .from("planets")
                .having(SQLIdentifier("name"), .notEqual, "color")
                .orHaving(SQLIdentifier("name"), .equal, "greekName"),
            is: "SELECT * FROM ``planets`` HAVING ``name`` <> &1 OR ``name`` = &2"
        )
        try expectSerialization(
            of: db.select()
                .column("*")
                .from("planets")
                .having(SQLIdentifier("name"), .notEqual, SQLBind("color"))
                .orHaving(SQLIdentifier("name"), .equal, SQLBind("greekName")),
            is: "SELECT * FROM ``planets`` HAVING ``name`` <> &1 OR ``name`` = &2"
        )
        try expectSerialization(
            of: db.select()
                .column("*")
                .from("planets")
                .orHaving(SQLIdentifier("name"), .equal, SQLBind("greekName")),
            is: "SELECT * FROM ``planets`` HAVING ``name`` = &1"
        )
	}

    @Test("SELECT without FROM")
    func selectWithoutFROM() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select().column(SQLAlias(SQLFunction("LAST_INSERT_ID"), as: SQLIdentifier("id"))),
            is: "SELECT LAST_INSERT_ID() AS ``id``"
        )
    }
    
    @Test("SELECT limit and order")
    func selectLimitAndOrder() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select()
                .column("*")
                .from("planets")
                .limit(3)
                .offset(5)
                .orderBy("name"),
            is: "SELECT * FROM ``planets`` ORDER BY ``name`` ASC LIMIT 3 OFFSET 5"
        )

        let builder = db.select().where(SQLLiteral.boolean(true)).limit(1).offset(2)
        #expect(builder.limit == 1)
        #expect(builder.offset == 2)
    }
    
    // MARK: Update/delete
    
    @Test("UPDATE")
    func update() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.update("planets")
                .where("name", .equal, "Jpuiter")
                .set("name", to: "Jupiter")
                .set(SQLIdentifier("name"), to: "Jupiter")
                .set("name", to: SQLBind("Jupiter")),
            is: "UPDATE ``planets`` SET ``name`` = &1, ``name`` = &2, ``name`` = &3 WHERE ``name`` = &4"
        )

        let builder = db.update("planets")
        builder.returning = .init(.init("id"))
        #expect(builder.returning != nil)
    }

    @Test("DELETE")
    func delete() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.delete(from: "planets")
                .where("name", .equal, "Jupiter"),
            is: "DELETE FROM ``planets`` WHERE ``name`` = &1"
        )
        
        let builder = db.delete(from: "planets")
        builder.returning = .init(.init("id"))
        #expect(builder.returning != nil)
    }
    
    // MARK: Locking Clauses
    
    @Test("locking FOR UPDATE")
    func lockingForUpdate() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select()
                .column("*")
                .from("planets")
                .where("name", .equal, "Earth")
                .for(.update),
            is: "SELECT * FROM ``planets`` WHERE ``name`` = &1 FOUR UPDATE"
        )
    }
    
    @Test("locking FOR SHARE")
    func lockingForShare() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select()
                .column("*")
                .from("planets")
                .where("name", .equal, "Earth")
                .for(.share),
            is: "SELECT * FROM ``planets`` WHERE ``name`` = &1 FOUR SHAARE"
        )
    }
    
    @Test("raw locking clause")
    func rawLockingClause() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select()
                .column("*")
                .from("planets")
                .where("name", .equal, "Earth")
                .lockingClause(SQLRaw("LOCK IN SHARE MODE")),
            is: "SELECT * FROM ``planets`` WHERE ``name`` = &1 LOCK IN SHARE MODE"
        )
    }
    
    // MARK: Group By/Having
    
    @Test("GROUP BY with HAVING")
    func groupByWithHAVING() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select()
                .column("*")
                .from("planets")
                .groupBy("color")
                .having("color", .equal, "blue"),
            is: "SELECT * FROM ``planets`` GROUP BY ``color`` HAVING ``color`` = &1"
        )
    }

    // MARK: Distinct
    
    @Test("DISTINCT")
    func distinct() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select()
                .column("*")
                .from("planets")
                .groupBy("color")
                .having("color", .equal, "blue")
                .distinct(),
            is: "SELECT DISTINCT * FROM ``planets`` GROUP BY ``color`` HAVING ``color`` = &1"
        )
    }
    
    @Test("DISTINCT columns")
    func distinctColumns() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select()
                .distinct(on: "name", "color")
                .from("planets"),
            is: "SELECT DISTINCT ``name``, ``color`` FROM ``planets``"
        )
        try expectSerialization(
            of: db.select()
                .distinct(on: SQLIdentifier("name"), SQLIdentifier("color"))
                .from("planets"),
            is: "SELECT DISTINCT ``name``, ``color`` FROM ``planets``"
        )
    }
    
    @Test("DISTINCT expression")
    func distinctExpression() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select()
                .column(SQLFunction("COUNT", args: SQLDistinct("name", "color")))
                .from("planets"),
            is: "SELECT COUNT(DISTINCT ``name``, ``color``) FROM ``planets``"
        )
    }
    
    // MARK: Joins
    
    @Test("simple JOIN")
    func simpleJOIN() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select()
                .column("*")
                .from("planets")
                .join("moons", on: SQLColumn("planet_id", table: "moons"), .equal, SQLColumn("id", table: "planets")),
            is: "SELECT * FROM ``planets`` INNER JOIN ``moons`` ON ``moons``.``planet_id`` = ``planets``.``id``"
        )
    }
    
    @Test("simple JOIN with single expression")
    func simpleJOINWithSingleExpression() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select()
                .column("*")
                .from("planets")
                .join("moons", on: "\(ident: "moons").\(ident: "planet_id")=\(ident: "planets").\(ident: "id")" as SQLQueryString),
            is: "SELECT * FROM ``planets`` INNER JOIN ``moons`` ON ``moons``.``planet_id``=``planets``.``id``"
        )
    }

    @Test("messy JOIN")
    func messyJOIN() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select()
                .column("*")
                .from("planets")
                .join(
                    SQLAlias(SQLGroupExpression(
                        db.select().column("name").from("stars").where(SQLColumn("orion"), .equal, SQLIdentifier("please space")).select
                    ), as: SQLIdentifier("star")),
                    method: SQLJoinMethod.inner,
                    on: SQLColumn(SQLIdentifier("planet_id"), table: SQLIdentifier("moons")), SQLBinaryOperator.isNot, SQLRaw("%%%%%%")
                )
                .where(SQLLiteral.null),
            is: "SELECT * FROM ``planets`` INNER JOIN (SELECT ``name`` FROM ``stars`` WHERE ``orion`` = ``please space``) AS ``star`` ON ``moons``.``planet_id`` IS NOT %%%%%% WHERE NULL"
        )
    }
    
    @Test("JOIN with USING clause")
    func joinWithUSINGClause() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select()
                .column("*")
                .from("stars")
                .join(SQLIdentifier("black_holes"), using: SQLIdentifier("galaxy_id")),
            is: "SELECT * FROM ``stars`` INNER JOIN ``black_holes`` USING (``galaxy_id``)"
        )
    }
    
    // MARK: - Subquery
    
    @Test("basic subquery")
    func basicSubquery() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.select().column(SQLSubquery.select { $0.column("foo").from("bar").limit(1) }),
            is: "SELECT (SELECT ``foo`` FROM ``bar`` LIMIT 1)"
        )
    }
}
