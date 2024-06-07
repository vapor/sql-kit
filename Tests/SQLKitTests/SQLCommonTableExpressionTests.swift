import SQLKit
import XCTest

final class SQLCommonTableExpressionTests: XCTestCase {
    var db = TestDatabase()

    override class func setUp() {
        XCTAssert(isLoggingConfigured)
    }
    
    func testSelectQueryWithCTE() {
        XCTAssertSerialization(
            of: self.db.select().with("a", columns: ["b"], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).column(SQLColumn("b", table: "a")),
            is: "WITH ``a`` (``b``) AS (SELECT 1) SELECT ``a``.``b``"
        )

        XCTAssertSerialization(
            of: self.db.select().with(SQLIdentifier("a"), columns: ["b"], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).column(SQLColumn("b", table: "a")),
            is: "WITH ``a`` (``b``) AS (SELECT 1) SELECT ``a``.``b``"
        )

        XCTAssertSerialization(
            of: self.db.select().with("a", columns: [SQLIdentifier("b")], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).column(SQLColumn("b", table: "a")),
            is: "WITH ``a`` (``b``) AS (SELECT 1) SELECT ``a``.``b``"
        )

        XCTAssertSerialization(
            of: self.db.select().with(SQLIdentifier("a"), columns: [SQLIdentifier("b")], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).column(SQLColumn("b", table: "a")),
            is: "WITH ``a`` (``b``) AS (SELECT 1) SELECT ``a``.``b``"
        )

        XCTAssertSerialization(
            of: self.db.select().with(recursive: "a", columns: ["b"], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).column(SQLColumn("b", table: "a")),
            is: "WITH RECURSIVE ``a`` (``b``) AS (SELECT 1) SELECT ``a``.``b``"
        )

        XCTAssertSerialization(
            of: self.db.select().with(recursive: SQLIdentifier("a"), columns: ["b"], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).column(SQLColumn("b", table: "a")),
            is: "WITH RECURSIVE ``a`` (``b``) AS (SELECT 1) SELECT ``a``.``b``"
        )

        XCTAssertSerialization(
            of: self.db.select().with(recursive: "a", columns: [SQLIdentifier("b")], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).column(SQLColumn("b", table: "a")),
            is: "WITH RECURSIVE ``a`` (``b``) AS (SELECT 1) SELECT ``a``.``b``"
        )

        XCTAssertSerialization(
            of: self.db.select().with(recursive: SQLIdentifier("a"), columns: [SQLIdentifier("b")], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).column(SQLColumn("b", table: "a")),
            is: "WITH RECURSIVE ``a`` (``b``) AS (SELECT 1) SELECT ``a``.``b``"
        )
    }

    func testUpdateQueryWithCTE() {
        XCTAssertSerialization(
            of: self.db.update("t").with("a", columns: ["b"], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).set("c", to: SQLColumn("b", table: "a")),
            is: "WITH ``a`` (``b``) AS (SELECT 1) UPDATE ``t`` SET ``c`` = ``a``.``b``"
        )

        XCTAssertSerialization(
            of: self.db.update("t").with(SQLIdentifier("a"), columns: ["b"], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).set("c", to: SQLColumn("b", table: "a")),
            is: "WITH ``a`` (``b``) AS (SELECT 1) UPDATE ``t`` SET ``c`` = ``a``.``b``"
        )

        XCTAssertSerialization(
            of: self.db.update("t").with("a", columns: [SQLIdentifier("b")], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).set("c", to: SQLColumn("b", table: "a")),
            is: "WITH ``a`` (``b``) AS (SELECT 1) UPDATE ``t`` SET ``c`` = ``a``.``b``"
        )

        XCTAssertSerialization(
            of: self.db.update("t").with(SQLIdentifier("a"), columns: [SQLIdentifier("b")], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).set("c", to: SQLColumn("b", table: "a")),
            is: "WITH ``a`` (``b``) AS (SELECT 1) UPDATE ``t`` SET ``c`` = ``a``.``b``"
        )

        XCTAssertSerialization(
            of: self.db.update("t").with(recursive: "a", columns: ["b"], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).set("c", to: SQLColumn("b", table: "a")),
            is: "WITH RECURSIVE ``a`` (``b``) AS (SELECT 1) UPDATE ``t`` SET ``c`` = ``a``.``b``"
        )

        XCTAssertSerialization(
            of: self.db.update("t").with(recursive: SQLIdentifier("a"), columns: ["b"], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).set("c", to: SQLColumn("b", table: "a")),
            is: "WITH RECURSIVE ``a`` (``b``) AS (SELECT 1) UPDATE ``t`` SET ``c`` = ``a``.``b``"
        )

        XCTAssertSerialization(
            of: self.db.update("t").with(recursive: "a", columns: [SQLIdentifier("b")], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).set("c", to: SQLColumn("b", table: "a")),
            is: "WITH RECURSIVE ``a`` (``b``) AS (SELECT 1) UPDATE ``t`` SET ``c`` = ``a``.``b``"
        )

        XCTAssertSerialization(
            of: self.db.update("t").with(recursive: SQLIdentifier("a"), columns: [SQLIdentifier("b")], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).set("c", to: SQLColumn("b", table: "a")),
            is: "WITH RECURSIVE ``a`` (``b``) AS (SELECT 1) UPDATE ``t`` SET ``c`` = ``a``.``b``"
        )
    }

    func testInsertQueryWithCTE() {
        XCTAssertSerialization(
            of: self.db.insert(into: "t").with("a", columns: ["b"], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).columns("c").values(SQLColumn("b", table: "a")),
            is: "WITH ``a`` (``b``) AS (SELECT 1) INSERT INTO ``t`` (``c``) VALUES (``a``.``b``)"
        )

        XCTAssertSerialization(
            of: self.db.insert(into: "t").with(SQLIdentifier("a"), columns: ["b"], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).columns("c").values(SQLColumn("b", table: "a")),
            is: "WITH ``a`` (``b``) AS (SELECT 1) INSERT INTO ``t`` (``c``) VALUES (``a``.``b``)"
        )

        XCTAssertSerialization(
            of: self.db.insert(into: "t").with("a", columns: [SQLIdentifier("b")], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).columns("c").values(SQLColumn("b", table: "a")),
            is: "WITH ``a`` (``b``) AS (SELECT 1) INSERT INTO ``t`` (``c``) VALUES (``a``.``b``)"
        )

        XCTAssertSerialization(
            of: self.db.insert(into: "t").with(SQLIdentifier("a"), columns: [SQLIdentifier("b")], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).columns("c").values(SQLColumn("b", table: "a")),
            is: "WITH ``a`` (``b``) AS (SELECT 1) INSERT INTO ``t`` (``c``) VALUES (``a``.``b``)"
        )

        XCTAssertSerialization(
            of: self.db.insert(into: "t").with(recursive: "a", columns: ["b"], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).columns("c").values(SQLColumn("b", table: "a")),
            is: "WITH RECURSIVE ``a`` (``b``) AS (SELECT 1) INSERT INTO ``t`` (``c``) VALUES (``a``.``b``)"
        )

        XCTAssertSerialization(
            of: self.db.insert(into: "t").with(recursive: SQLIdentifier("a"), columns: ["b"], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).columns("c").values(SQLColumn("b", table: "a")),
            is: "WITH RECURSIVE ``a`` (``b``) AS (SELECT 1) INSERT INTO ``t`` (``c``) VALUES (``a``.``b``)"
        )

        XCTAssertSerialization(
            of: self.db.insert(into: "t").with(recursive: "a", columns: [SQLIdentifier("b")], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).columns("c").values(SQLColumn("b", table: "a")),
            is: "WITH RECURSIVE ``a`` (``b``) AS (SELECT 1) INSERT INTO ``t`` (``c``) VALUES (``a``.``b``)"
        )

        XCTAssertSerialization(
            of: self.db.insert(into: "t").with(recursive: SQLIdentifier("a"), columns: [SQLIdentifier("b")], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).columns("c").values(SQLColumn("b", table: "a")),
            is: "WITH RECURSIVE ``a`` (``b``) AS (SELECT 1) INSERT INTO ``t`` (``c``) VALUES (``a``.``b``)"
        )
    }

    func testDeleteQueryWithCTE() {
        XCTAssertSerialization(
            of: self.db.delete(from: "t").with("a", columns: ["b"], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).where("c", .equal, SQLColumn("b", table: "a")),
            is: "WITH ``a`` (``b``) AS (SELECT 1) DELETE FROM ``t`` WHERE ``c`` = ``a``.``b``"
        )

        XCTAssertSerialization(
            of: self.db.delete(from: "t").with(SQLIdentifier("a"), columns: ["b"], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).where("c", .equal, SQLColumn("b", table: "a")),
            is: "WITH ``a`` (``b``) AS (SELECT 1) DELETE FROM ``t`` WHERE ``c`` = ``a``.``b``"
        )

        XCTAssertSerialization(
            of: self.db.delete(from: "t").with("a", columns: [SQLIdentifier("b")], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).where("c", .equal, SQLColumn("b", table: "a")),
            is: "WITH ``a`` (``b``) AS (SELECT 1) DELETE FROM ``t`` WHERE ``c`` = ``a``.``b``"
        )

        XCTAssertSerialization(
            of: self.db.delete(from: "t").with(SQLIdentifier("a"), columns: [SQLIdentifier("b")], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).where("c", .equal, SQLColumn("b", table: "a")),
            is: "WITH ``a`` (``b``) AS (SELECT 1) DELETE FROM ``t`` WHERE ``c`` = ``a``.``b``"
        )

        XCTAssertSerialization(
            of: self.db.delete(from: "t").with(recursive: "a", columns: ["b"], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).where("c", .equal, SQLColumn("b", table: "a")),
            is: "WITH RECURSIVE ``a`` (``b``) AS (SELECT 1) DELETE FROM ``t`` WHERE ``c`` = ``a``.``b``"
        )

        XCTAssertSerialization(
            of: self.db.delete(from: "t").with(recursive: SQLIdentifier("a"), columns: ["b"], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).where("c", .equal, SQLColumn("b", table: "a")),
            is: "WITH RECURSIVE ``a`` (``b``) AS (SELECT 1) DELETE FROM ``t`` WHERE ``c`` = ``a``.``b``"
        )

        XCTAssertSerialization(
            of: self.db.delete(from: "t").with(recursive: "a", columns: [SQLIdentifier("b")], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).where("c", .equal, SQLColumn("b", table: "a")),
            is: "WITH RECURSIVE ``a`` (``b``) AS (SELECT 1) DELETE FROM ``t`` WHERE ``c`` = ``a``.``b``"
        )

        XCTAssertSerialization(
            of: self.db.delete(from: "t").with(recursive: SQLIdentifier("a"), columns: [SQLIdentifier("b")], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).where("c", .equal, SQLColumn("b", table: "a")),
            is: "WITH RECURSIVE ``a`` (``b``) AS (SELECT 1) DELETE FROM ``t`` WHERE ``c`` = ``a``.``b``"
        )
    }

    func testUnionQueryWithCTE() {
        self.db._dialect.unionFeatures = [.union, .unionAll, .intersect, .intersectAll, .except, .exceptAll, .parenthesizedSubqueries]

        XCTAssertSerialization(
            of: self.db.union { $0 }.with("a", columns: ["b"], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).union(all: { $0.column(SQLColumn("b", table: "a")) }),
            is: "WITH ``a`` (``b``) AS (SELECT 1) (SELECT) UNION ALL (SELECT ``a``.``b``)"
        )

        XCTAssertSerialization(
            of: self.db.union { $0 }.with(SQLIdentifier("a"), columns: ["b"], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).union(all: { $0.column(SQLColumn("b", table: "a")) }),
            is: "WITH ``a`` (``b``) AS (SELECT 1) (SELECT) UNION ALL (SELECT ``a``.``b``)"
        )

        XCTAssertSerialization(
            of: self.db.union { $0 }.with("a", columns: [SQLIdentifier("b")], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).union(all: { $0.column(SQLColumn("b", table: "a")) }),
            is: "WITH ``a`` (``b``) AS (SELECT 1) (SELECT) UNION ALL (SELECT ``a``.``b``)"
        )

        XCTAssertSerialization(
            of: self.db.union { $0 }.with(SQLIdentifier("a"), columns: [SQLIdentifier("b")], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).union(all: { $0.column(SQLColumn("b", table: "a")) }),
            is: "WITH ``a`` (``b``) AS (SELECT 1) (SELECT) UNION ALL (SELECT ``a``.``b``)"
        )

        XCTAssertSerialization(
            of: self.db.union { $0 }.with(recursive: "a", columns: ["b"], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).union(all: { $0.column(SQLColumn("b", table: "a")) }),
            is: "WITH RECURSIVE ``a`` (``b``) AS (SELECT 1) (SELECT) UNION ALL (SELECT ``a``.``b``)"
        )

        XCTAssertSerialization(
            of: self.db.union { $0 }.with(recursive: SQLIdentifier("a"), columns: ["b"], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).union(all: { $0.column(SQLColumn("b", table: "a")) }),
            is: "WITH RECURSIVE ``a`` (``b``) AS (SELECT 1) (SELECT) UNION ALL (SELECT ``a``.``b``)"
        )

        XCTAssertSerialization(
            of: self.db.union { $0 }.with(recursive: "a", columns: [SQLIdentifier("b")], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).union(all: { $0.column(SQLColumn("b", table: "a")) }),
            is: "WITH RECURSIVE ``a`` (``b``) AS (SELECT 1) (SELECT) UNION ALL (SELECT ``a``.``b``)"
        )

        XCTAssertSerialization(
            of: self.db.union { $0 }.with(recursive: SQLIdentifier("a"), columns: [SQLIdentifier("b")], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) }).union(all: { $0.column(SQLColumn("b", table: "a")) }),
            is: "WITH RECURSIVE ``a`` (``b``) AS (SELECT 1) (SELECT) UNION ALL (SELECT ``a``.``b``)"
        )
    }

}
