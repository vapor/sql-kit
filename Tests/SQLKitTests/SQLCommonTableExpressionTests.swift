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
    
    func testMultipleCTEs() {
        XCTAssertSerialization(
            of: self.db.select()
                .with("a", columns: ["b"], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) })
                .with("d", columns: ["e"], as: SQLSubquery.select { $0.column(SQLLiteral.numeric("1")) })
                .column(SQLColumn("b", table: "a")),
            is: "WITH ``a`` (``b``) AS (SELECT 1), ``d`` (``e``) AS (SELECT 1) SELECT ``a``.``b``"
        )
    }
    
    func testCodeCoverage() {
        var query = self.db.select().column(SQLColumn("b", table: "a")).select
        query.tableExpressionGroup = .init(tableExpressions: [
            SQLCommonTableExpression(alias: SQLIdentifier("x"), query: SQLUnsafeRaw("VALUES(``1``)")),
            SQLCommonTableExpression(alias: SQLIdentifier("x"), query: SQLGroupExpression(SQLUnsafeRaw("VALUES(``1``)"))),
            SQLGroupExpression(SQLUnsafeRaw("FOO"))
        ])
        
        XCTAssertSerialization(of: self.db.unsafeRaw("\(query)"), is: "WITH ``x`` AS (VALUES(``1``)), ``x`` AS (VALUES(``1``)), (FOO) SELECT ``a``.``b``")
    }
    
    func testMoreRealisticCTEs() {
        // Simple sub-SELECT avoidance
        // Taken from https://www.postgresql.org/docs/16/queries-with.html#QUERIES-WITH-SELECT
        self.db._dialect.identifierQuote = SQLUnsafeRaw("\"")
        XCTAssertSerialization(
            of: self.db.select()
                .with("regional_sales", as: SQLSubquery.select { $0
                    .column("region").column(SQLFunction("SUM", args: SQLColumn("amount")), as: "total_sales").from("orders").groupBy("region")
                })
                .with("top_regions", as: SQLSubquery.select { $0
                    .column("region").from("regional_sales")
                    .where("total_sales", .greaterThan, SQLSubquery.select { $0
                        .column(SQLBinaryExpression(SQLFunction("SUM", args: SQLIdentifier("total_sales")), .divide, SQLLiteral.numeric("10")))
                        .from("regional_sales")
                    })
                })
                .columns("region", "product")
                .column(SQLFunction("SUM", args: SQLColumn("quantity")), as: "product_units")
                .column(SQLFunction("SUM", args: SQLColumn("amount")), as: "product_sales")
                .from("orders").where("region", .in, SQLSubquery.select { $0.column("region").from("top_regions") }).groupBy("region").groupBy("product"),
            is: """
                WITH
                "regional_sales" AS (SELECT "region", SUM("amount") AS "total_sales" FROM "orders" GROUP BY "region"),
                "top_regions" AS (SELECT "region" FROM "regional_sales" WHERE "total_sales" > (SELECT SUM("total_sales") / 10 FROM "regional_sales"))
                SELECT "region", "product", SUM("quantity") AS "product_units", SUM("amount") AS "product_sales"
                FROM "orders"
                WHERE "region" IN (SELECT "region" FROM "top_regions")
                GROUP BY "region", "product"
                """.replacing("\n", with: " ")
        )
        
        // Fibonacci series generator
        // Taken from https://dev.mysql.com/doc/refman/8.4/en/with.html#common-table-expressions-recursive-fibonacci-series
        self.db._dialect.identifierQuote = SQLUnsafeRaw("`")
        self.db._dialect.unionFeatures = [.union, .unionAll]
        XCTAssertSerialization(
            of: self.db.select()
                .with(recursive: "fibonacci", columns: ["n", "fib_n", "next_fib_n"], as: SQLSubquery.union { $0
                    .columns(SQLLiteral.numeric("1"), SQLLiteral.numeric("0"), SQLLiteral.numeric("1"))
                }.union(all: { $0
                    .column(SQLBinaryExpression(SQLColumn("n"), .add, SQLLiteral.numeric("1")))
                    .column("next_fib_n")
                    .column(SQLBinaryExpression(SQLColumn("fib_n"), .add, SQLColumn("next_fib_n")))
                    .from("fibonacci")
                    .where("n", .lessThan, SQLLiteral.numeric("10"))
                })
                .finish())
                .column(SQLLiteral.all)
                .from("fibonacci"),
            is: """
                WITH RECURSIVE `fibonacci` (`n`, `fib_n`, `next_fib_n`) AS (
                    SELECT 1, 0, 1
                    UNION ALL
                    SELECT `n` + 1, `next_fib_n`, `fib_n` + `next_fib_n` FROM `fibonacci` WHERE `n` < 10
                )
                SELECT * FROM `fibonacci`
                """.replacing("    ", with: "").replacing("(\n", with: "(").replacing("\n)", with: ")").replacing("\n", with: " ")
        )
    }
}
