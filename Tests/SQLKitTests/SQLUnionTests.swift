import SQLKit
import XCTest

final class SQLUnionTests: XCTestCase {
    var db = TestDatabase()

    override class func setUp() {
        XCTAssert(isLoggingConfigured)
    }
    
    // MARK: Top-level unions

    func testUnion_UNION() {
        // Check that queries are explicitly malformed without the feature flags
        self.db._dialect.unionFeatures = []

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").union(distinct: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` SELECT ``id`` FROM ``t2``"
        )
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").union(all: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` SELECT ``id`` FROM ``t2``"
        )

        // Test that queries are correctly formed with the feature flags
        self.db._dialect.unionFeatures.formUnion([.union, .unionAll])

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").union(distinct: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` UNION SELECT ``id`` FROM ``t2``"
        )
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").union(all: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` UNION ALL SELECT ``id`` FROM ``t2``"
        )

        // Test that the explicit distinct flag is respected
        self.db._dialect.unionFeatures.insert(.explicitDistinct)
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").union(distinct: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` UNION DISTINCT SELECT ``id`` FROM ``t2``"
        )
    }
    
    func testUnion_INTERSECT() {
        // Check that queries are explicitly malformed without the feature flags
        self.db._dialect.unionFeatures = []

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").intersect(distinct: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` SELECT ``id`` FROM ``t2``"
        )
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").intersect(all: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` SELECT ``id`` FROM ``t2``"
        )

        // Test that queries are correctly formed with the feature flags
        self.db._dialect.unionFeatures.formUnion([.intersect, .intersectAll])

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").intersect(distinct: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` INTERSECT SELECT ``id`` FROM ``t2``"
        )
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").intersect(all: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` INTERSECT ALL SELECT ``id`` FROM ``t2``"
        )

        // Test that the explicit distinct flag is respected
        self.db._dialect.unionFeatures.insert(.explicitDistinct)

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").intersect(distinct: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` INTERSECT DISTINCT SELECT ``id`` FROM ``t2``"
        )
    }
    
    func testUnion_EXCEPT() {
        // Check that queries are explicitly malformed without the feature flags
        self.db._dialect.unionFeatures = []

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").except(distinct: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` SELECT ``id`` FROM ``t2``"
        )
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").except(all: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` SELECT ``id`` FROM ``t2``"
        )

        // Test that queries are correctly formed with the feature flags
        self.db._dialect.unionFeatures.formUnion([.except, .exceptAll])

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").except(distinct: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` EXCEPT SELECT ``id`` FROM ``t2``"
        )
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").except(all: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` EXCEPT ALL SELECT ``id`` FROM ``t2``"
        )
        
        // Test that the explicit distinct flag is respected
        self.db._dialect.unionFeatures.insert(.explicitDistinct)

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").except(distinct: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` EXCEPT DISTINCT SELECT ``id`` FROM ``t2``"
        )
    }
    
    func testUnionWithParenthesizedSubqueriesFlag() {
        // Test that the parenthesized subqueries flag does as expected, including for multiple unions
        self.db._dialect.unionFeatures = [.union, .unionAll, .parenthesizedSubqueries]
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").union(distinct: { $0.column("id").from("t2") }),
            is: "(SELECT ``id`` FROM ``t1``) UNION (SELECT ``id`` FROM ``t2``)"
        )
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").union(distinct: { $0.column("id").from("t2") }).union(distinct: { $0.column("id").from("t3") }),
            is: "(SELECT ``id`` FROM ``t1``) UNION (SELECT ``id`` FROM ``t2``) UNION (SELECT ``id`` FROM ``t3``)"
        )
    }
    
    func testUnionChaining() {
        // Test that chaining and mixing multiple union types works
        self.db._dialect.unionFeatures = [.union, .unionAll, .intersect, .intersectAll, .except, .exceptAll, .explicitDistinct, .parenthesizedSubqueries]
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1")
                .union(distinct:     { $0.column("id").from("t2") })
                .union(all:          { $0.column("id").from("t3") })
                .union(              { $0.column("id").from("t23") })
                .intersect(distinct: { $0.column("id").from("t4") })
                .intersect(all:      { $0.column("id").from("t5") })
                .intersect(          { $0.column("id").from("t45") })
                .except(distinct:    { $0.column("id").from("t6") })
                .except(all:         { $0.column("id").from("t7") })
                .except(             { $0.column("id").from("t67") }),
            is: "(SELECT ``id`` FROM ``t1``) UNION DISTINCT (SELECT ``id`` FROM ``t2``) UNION ALL (SELECT ``id`` FROM ``t3``) UNION DISTINCT (SELECT ``id`` FROM ``t23``) INTERSECT DISTINCT (SELECT ``id`` FROM ``t4``) INTERSECT ALL (SELECT ``id`` FROM ``t5``) INTERSECT DISTINCT (SELECT ``id`` FROM ``t45``) EXCEPT DISTINCT (SELECT ``id`` FROM ``t6``) EXCEPT ALL (SELECT ``id`` FROM ``t7``) EXCEPT DISTINCT (SELECT ``id`` FROM ``t67``)"
        )
    }
    
    func testOneQueryUnion() {
        // Test that having a single entry in the union just executes that entry
        XCTAssertSerialization(
            of: self.db.union { $0.column("id").from("t1") },
            is: "SELECT ``id`` FROM ``t1``"
        )
    }
    
    func testUnionSubtypesFromSelect() {
        self.db._dialect.unionFeatures = [.union, .unionAll, .intersect, .intersectAll, .except, .exceptAll, .parenthesizedSubqueries]
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").union({ $0.column("id").from("t2") }),
            is: "(SELECT ``id`` FROM ``t1``) UNION (SELECT ``id`` FROM ``t2``)"
        )

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").intersect({ $0.column("id").from("t2") }),
            is: "(SELECT ``id`` FROM ``t1``) INTERSECT (SELECT ``id`` FROM ``t2``)"
        )

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").except({ $0.column("id").from("t2") }),
            is: "(SELECT ``id`` FROM ``t1``) EXCEPT (SELECT ``id`` FROM ``t2``)"
        )
    }
    
    func testUnionOverallModifiers() {
        // Test LIMIT and OFFSET
        self.db._dialect.unionFeatures = [.union, .unionAll, .intersect, .intersectAll, .except, .exceptAll, .parenthesizedSubqueries]
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").union({ $0.column("id").from("t2") }).limit(3).offset(5),
            is: "(SELECT ``id`` FROM ``t1``) UNION (SELECT ``id`` FROM ``t2``) LIMIT 3 OFFSET 5"
        )
        
        // Cover the property getters
        let builder = self.db.union({ $0.where(SQLLiteral.boolean(true)) }).limit(1).offset(2)
        XCTAssertEqual(builder.limit, 1)
        XCTAssertEqual(builder.offset, 2)
        
        // Test multiple ORDER BY statements
        XCTAssertSerialization(
            of: self.db.select().column("*").from("t1").union({ $0.column("*").from("t2") }).orderBy("id").orderBy("name", .descending),
            is: "(SELECT * FROM ``t1``) UNION (SELECT * FROM ``t2``) ORDER BY ``id`` ASC, ``name`` DESC"
        )
    }
    
    func testUnionAddMethod() {
        var query = SQLUnion(initialQuery: self.db.select().columns("*").select)
        query.add(self.db.select().columns("*").select, all: true)
        query.add(self.db.select().columns("*").select, all: false)
        
        self.db._dialect.unionFeatures = []
        XCTAssertSerialization(of: self.db.raw("\(query)"), is: "SELECT * SELECT * SELECT *")

        self.db._dialect.unionFeatures = [.union, .unionAll]
        XCTAssertSerialization(of: self.db.raw("\(query)"), is: "SELECT * UNION ALL SELECT * UNION SELECT *")
    }

    // MARK: Subquery unions

    func testUnionSubquery_UNION() {
        // Check that queries are explicitly malformed without the feature flags
        self.db._dialect.unionFeatures = []

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .union(distinct: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` SELECT ``id`` FROM ``t3``)"
        )
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .union(all: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` SELECT ``id`` FROM ``t3``)"
        )

        // Test that queries are correctly formed with the feature flags
        self.db._dialect.unionFeatures.formUnion([.union, .unionAll])

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .union(distinct: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` UNION SELECT ``id`` FROM ``t3``)"
        )
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .union(all: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` UNION ALL SELECT ``id`` FROM ``t3``)"
        )

        // Test that the explicit distinct flag is respected
        self.db._dialect.unionFeatures.insert(.explicitDistinct)
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .union(distinct: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` UNION DISTINCT SELECT ``id`` FROM ``t3``)"
        )
    }
    
    func testUnionSubquery_INTERSECT() {
        // Check that queries are explicitly malformed without the feature flags
        self.db._dialect.unionFeatures = []

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .intersect(distinct: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` SELECT ``id`` FROM ``t3``)"
        )
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .intersect(all: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` SELECT ``id`` FROM ``t3``)"
        )

        // Test that queries are correctly formed with the feature flags
        self.db._dialect.unionFeatures.formUnion([.intersect, .intersectAll])

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .intersect(distinct: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` INTERSECT SELECT ``id`` FROM ``t3``)"
        )
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .intersect(all: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` INTERSECT ALL SELECT ``id`` FROM ``t3``)"
        )

        // Test that the explicit distinct flag is respected
        self.db._dialect.unionFeatures.insert(.explicitDistinct)

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .intersect(distinct: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` INTERSECT DISTINCT SELECT ``id`` FROM ``t3``)"
        )
    }
    
    func testUnionSubquery_EXCEPT() {
        // Check that queries are explicitly malformed without the feature flags
        self.db._dialect.unionFeatures = []

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .except(distinct: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` SELECT ``id`` FROM ``t3``)"
        )
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .except(all: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` SELECT ``id`` FROM ``t3``)"
        )

        // Test that queries are correctly formed with the feature flags
        self.db._dialect.unionFeatures.formUnion([.except, .exceptAll])

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .except(distinct: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` EXCEPT SELECT ``id`` FROM ``t3``)"
        )
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .except(all: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` EXCEPT ALL SELECT ``id`` FROM ``t3``)"
        )
        
        // Test that the explicit distinct flag is respected
        self.db._dialect.unionFeatures.insert(.explicitDistinct)

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .except(distinct: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` EXCEPT DISTINCT SELECT ``id`` FROM ``t3``)"
        )
    }

}
