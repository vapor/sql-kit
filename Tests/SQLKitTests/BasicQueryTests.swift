import SQLKit
import XCTest

final class BasicQueryTests: XCTestCase {
    var db = TestDatabase()

    override class func setUp() {
        XCTAssert(isLoggingConfigured)
    }
        
    // MARK: Select
    
    func testSelect_tableAllCols() {
        XCTAssertSerialization(
            of: self.db.select().column(SQLColumn(SQLLiteral.all, table: SQLIdentifier("planets"))).from("planets").where("name", .equal, SQLBind("Earth")),
            is: "SELECT ``planets``.* FROM ``planets`` WHERE ``name`` = &1"
        )
    }
    
    func testSelect_whereEncodable() {
        XCTAssertSerialization(
            of: self.db.select().column("*").from("planets").where("name", .equal, "Earth").orWhere("name", .equal, "Mars"),
            is: "SELECT * FROM ``planets`` WHERE ``name`` = &1 OR ``name`` = &2"
        )
    }
    
    func testSelect_whereArrayEncodableWithString() {
        XCTAssertSerialization(
            of: self.db.select().column("*").from("planets").where("name", .in, ["Earth", "Mars"]).orWhere("name", .in, ["Venus", "Mercury"]),
            is: "SELECT * FROM ``planets`` WHERE ``name`` IN (&1, &2) OR ``name`` IN (&3, &4)"
        )
    }

    func testSelect_whereArrayEncodableWithIdentifier() {
        XCTAssertSerialization(
            of: self.db.select().column("*").from("planets").where(SQLIdentifier("name"), .in, ["Earth", "Mars"]).orWhere(SQLIdentifier("name"), .in, ["Venus", "Mercury"]),
            is: "SELECT * FROM ``planets`` WHERE ``name`` IN (&1, &2) OR ``name`` IN (&3, &4)"
        )
    }

    func testSelect_whereGroup() {
        XCTAssertSerialization(
            of: self.db.select().column("*").from("planets")
                .where { $0.where("name", .equal, "Earth").orWhere("name", .equal, "Mars") }
                .orWhere { $0.where("color", .notEqual, "yellow") }
                .where("color", .equal, "blue"),
            is: "SELECT * FROM ``planets`` WHERE (``name`` = &1 OR ``name`` = &2) OR (``color`` <> &3) AND ``color`` = &4"
        )
    }
    
    func testSelect_whereEmptyGroup() {
        XCTAssertSerialization(
            of: self.db.select().column("*").from("planets").where { $0 }.orWhere { $0 }.where("color", .equal, "blue"),
            is: "SELECT * FROM ``planets`` WHERE ``color`` = &1"
        )
    }
    
    
    func testSelect_whereColumn() {
        XCTAssertSerialization(
            of: self.db.select().column("*").from("planets").where("name", .notEqual, column: "color").orWhere("name", .equal, column: "greekName"),
            is: "SELECT * FROM ``planets`` WHERE ``name`` <> ``color`` OR ``name`` = ``greekName``"
        )
	}

    func testSelect_havingEncodable() {
        XCTAssertSerialization(
            of: self.db.select().column("*").from("planets").having("name", .equal, "Earth").orHaving("name", .equal, "Mars"),
            is: "SELECT * FROM ``planets`` HAVING ``name`` = &1 OR ``name`` = &2"
        )
    }
    
    func testSelect_havingArrayEncodableWithString() {
        XCTAssertSerialization(
            of: self.db.select().column("*").from("planets").having("name", .in, ["Earth", "Mars"]).orHaving("name", .in, ["Venus", "Mercury"]),
            is: "SELECT * FROM ``planets`` HAVING ``name`` IN (&1, &2) OR ``name`` IN (&3, &4)"
        )
    }

    func testSelect_havingArrayEncodableWithIdentifier() {
        XCTAssertSerialization(
            of: self.db.select().column("*").from("planets").having(SQLIdentifier("name"), .in, ["Earth", "Mars"]).orHaving(SQLIdentifier("name"), .in, ["Venus", "Mercury"]),
            is: "SELECT * FROM ``planets`` HAVING ``name`` IN (&1, &2) OR ``name`` IN (&3, &4)"
        )
    }

    func testSelect_havingGroup() {
        XCTAssertSerialization(
            of: self.db.select().column("*").from("planets")
                .having { $0.having("name", .equal, "Earth").orHaving("name", .equal, "Mars") }
                .orHaving { $0.having("color", .notEqual, "yellow") }
                .having("color", .equal, "blue"),
            is: "SELECT * FROM ``planets`` HAVING (``name`` = &1 OR ``name`` = &2) OR (``color`` <> &3) AND ``color`` = &4"
        )
    }
    
    func testSelect_havingEmptyGroup() {
        XCTAssertSerialization(
            of: self.db.select().column("*").from("planets").having { $0 }.orHaving { $0 }.having("color", .equal, "blue"),
            is: "SELECT * FROM ``planets`` HAVING ``color`` = &1"
        )
    }
    
    
    func testSelect_havingColumn() {
        XCTAssertSerialization(
            of: self.db.select().column("*").from("planets").having("name", .notEqual, column: "color").orHaving("name", .equal, column: "greekName"),
            is: "SELECT * FROM ``planets`` HAVING ``name`` <> ``color`` OR ``name`` = ``greekName``"
        )
	}

    func testSelect_withoutFrom() {
        XCTAssertSerialization(
            of: self.db.select().column(SQLAlias.init(SQLFunction("LAST_INSERT_ID"), as: SQLIdentifier.init("id"))),
            is: "SELECT LAST_INSERT_ID() AS ``id``"
        )
    }
    
    func testSelect_limitAndOrder() {
        XCTAssertSerialization(
            of: self.db.select()
                .column("*")
                .from("planets")
                .limit(3)
                .offset(5)
                .orderBy("name"),
            is: "SELECT * FROM ``planets`` ORDER BY ``name`` ASC LIMIT 3 OFFSET 5"
        )
    }
    
    // MARK: Update/delete
    
    func testUpdate() {
        XCTAssertSerialization(
            of: self.db.update("planets")
                .where("name", .equal, "Jpuiter")
                .set("name", to: "Jupiter"),
            is: "UPDATE ``planets`` SET ``name`` = &1 WHERE ``name`` = &2"
        )

        let builder = self.db.update("planets")
        builder.returning = .init(.init("id"))
        XCTAssertNotNil(builder.returning)
    }

    func testDelete() {
        XCTAssertSerialization(
            of: self.db.delete(from: "planets")
                .where("name", .equal, "Jupiter"),
            is: "DELETE FROM ``planets`` WHERE ``name`` = &1"
        )
        
        let builder = self.db.delete(from: "planets")
        builder.returning = .init(.init("id"))
        XCTAssertNotNil(builder.returning)
    }
    
    // MARK: Locking Clauses
    
    func testLockingClause_forUpdate() {
        XCTAssertSerialization(
            of: self.db.select()
                .column("*")
                .from("planets")
                .where("name", .equal, "Earth")
                .for(.update),
            is: "SELECT * FROM ``planets`` WHERE ``name`` = &1 FOR UPDATE"
        )
    }
    
    func testLockingClause_forShare() {
        XCTAssertSerialization(
            of: self.db.select()
                .column("*")
                .from("planets")
                .where("name", .equal, "Earth")
                .for(.share),
            is: "SELECT * FROM ``planets`` WHERE ``name`` = &1 FOR SHARE"
        )
    }
    
    func testLockingClause_raw() {
        XCTAssertSerialization(
            of: self.db.select()
                .column("*")
                .from("planets")
                .where("name", .equal, "Earth")
                .lockingClause(SQLRaw("LOCK IN SHARE MODE")),
            is: "SELECT * FROM ``planets`` WHERE ``name`` = &1 LOCK IN SHARE MODE"
        )
    }
    
    // MARK: Group By/Having
    
    func testGroupByHaving() {
        XCTAssertSerialization(
            of: self.db.select()
                .column("*")
                .from("planets")
                .groupBy("color")
                .having("color", .equal, "blue"),
            is: "SELECT * FROM ``planets`` GROUP BY ``color`` HAVING ``color`` = &1"
        )
    }

    // MARK: Distinct
    
    func testDistinct() {
        XCTAssertSerialization(
            of: self.db.select()
                .column("*")
                .from("planets")
                .groupBy("color")
                .having("color", .equal, "blue")
                .distinct(),
            is: "SELECT DISTINCT * FROM ``planets`` GROUP BY ``color`` HAVING ``color`` = &1"
        )
    }
    
    func testDistinctColumns() {
        XCTAssertSerialization(
            of: self.db.select()
                .distinct(on: "name", "color")
                .from("planets"),
            is: "SELECT DISTINCT ``name``, ``color`` FROM ``planets``"
        )
    }
    
    func testDistinctExpression() {
        XCTAssertSerialization(
            of: self.db.select()
                .column(SQLFunction("COUNT", args: SQLDistinct("name", "color")))
                .from("planets"),
            is: "SELECT COUNT(DISTINCT ``name``, ``color``) FROM ``planets``"
        )
    }
    
    // MARK: Joins
    
    func testSimpleJoin() {
        XCTAssertSerialization(
            of: self.db.select()
                .column("*")
                .from("planets")
                .join("moons", on: "\(ident: "moons").\(ident: "planet_id")=\(ident: "planets").\(ident: "id")" as SQLQueryString),
            is: "SELECT * FROM ``planets`` INNER JOIN ``moons`` ON ``moons``.``planet_id``=``planets``.``id``"
        )
    }
    
    func testMessyJoin() {
        XCTAssertSerialization(
            of: self.db.select()
                .column("*")
                .from("planets")
                .join(
                    SQLAlias(SQLGroupExpression(
                        self.db.select().column("name").from("stars").where(SQLColumn("orion"), .equal, SQLIdentifier("please space")).select
                    ), as: SQLIdentifier("star")),
                    method: SQLJoinMethod.inner,
                    on: SQLColumn(SQLIdentifier("planet_id"), table: SQLIdentifier("moons")), SQLBinaryOperator.isNot, SQLRaw("%%%%%%")
                )
                .where(SQLLiteral.null),
            is: "SELECT * FROM ``planets`` INNER JOIN (SELECT ``name`` FROM ``stars`` WHERE ``orion`` = ``please space``) AS ``star`` ON ``moons``.``planet_id`` IS NOT %%%%%% WHERE NULL"
        )
    }
    
    // MARK: - Subquery
    
    func testBasicSubquery() {
        XCTAssertSerialization(
            of: self.db.select().column(SQLSubquery.select { $0.column("foo").from("bar").limit(1) }),
            is: "SELECT (SELECT ``foo`` FROM ``bar`` LIMIT 1)"
        )
    }
}
