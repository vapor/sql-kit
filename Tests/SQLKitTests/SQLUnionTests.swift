import SQLKit
import XCTest

final class SQLUnionTests: XCTestCase {
    var db = TestDatabase()

    override class func setUp() {
        XCTAssert(isLoggingConfigured)
    }
    
    // MARK: Unions

    func testUnion_UNION() {
        // Check that queries are explicitly malformed without the feature flags
        self.db._dialect.unionFeatures = []

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").union(distinct: { $0.column("id").from("t2") }),
            is: "SELECT `id` FROM `t1` SELECT `id` FROM `t2`"
        )
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").union(all: { $0.column("id").from("t2") }),
            is: "SELECT `id` FROM `t1` SELECT `id` FROM `t2`"
        )

        // Test that queries are correctly formed with the feature flags
        self.db._dialect.unionFeatures.formUnion([.union, .unionAll])

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").union(distinct: { $0.column("id").from("t2") }),
            is: "SELECT `id` FROM `t1` UNION SELECT `id` FROM `t2`"
        )
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").union(all: { $0.column("id").from("t2") }),
            is: "SELECT `id` FROM `t1` UNION ALL SELECT `id` FROM `t2`"
        )

        // Test that the explicit distinct flag is respected
        self.db._dialect.unionFeatures.insert(.explicitDistinct)
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").union(distinct: { $0.column("id").from("t2") }),
            is: "SELECT `id` FROM `t1` UNION DISTINCT SELECT `id` FROM `t2`"
        )
    }
    
    func testUnion_INTERSECT() {
        // Check that queries are explicitly malformed without the feature flags
        self.db._dialect.unionFeatures = []

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").intersect(distinct: { $0.column("id").from("t2") }),
            is: "SELECT `id` FROM `t1` SELECT `id` FROM `t2`"
        )
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").intersect(all: { $0.column("id").from("t2") }),
            is: "SELECT `id` FROM `t1` SELECT `id` FROM `t2`"
        )

        // Test that queries are correctly formed with the feature flags
        self.db._dialect.unionFeatures.formUnion([.intersect, .intersectAll])

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").intersect(distinct: { $0.column("id").from("t2") }),
            is: "SELECT `id` FROM `t1` INTERSECT SELECT `id` FROM `t2`"
        )
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").intersect(all: { $0.column("id").from("t2") }),
            is: "SELECT `id` FROM `t1` INTERSECT ALL SELECT `id` FROM `t2`"
        )

        // Test that the explicit distinct flag is respected
        self.db._dialect.unionFeatures.insert(.explicitDistinct)

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").intersect(distinct: { $0.column("id").from("t2") }),
            is: "SELECT `id` FROM `t1` INTERSECT DISTINCT SELECT `id` FROM `t2`"
        )
    }
    
    func testUnion_EXCEPT() {
        // Check that queries are explicitly malformed without the feature flags
        self.db._dialect.unionFeatures = []

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").except(distinct: { $0.column("id").from("t2") }),
            is: "SELECT `id` FROM `t1` SELECT `id` FROM `t2`"
        )
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").except(all: { $0.column("id").from("t2") }),
            is: "SELECT `id` FROM `t1` SELECT `id` FROM `t2`"
        )

        // Test that queries are correctly formed with the feature flags
        self.db._dialect.unionFeatures.formUnion([.except, .exceptAll])

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").except(distinct: { $0.column("id").from("t2") }),
            is: "SELECT `id` FROM `t1` EXCEPT SELECT `id` FROM `t2`"
        )
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").except(all: { $0.column("id").from("t2") }),
            is: "SELECT `id` FROM `t1` EXCEPT ALL SELECT `id` FROM `t2`"
        )
        
        // Test that the explicit distinct flag is respected
        self.db._dialect.unionFeatures.insert(.explicitDistinct)

        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").except(distinct: { $0.column("id").from("t2") }),
            is: "SELECT `id` FROM `t1` EXCEPT DISTINCT SELECT `id` FROM `t2`"
        )
    }
    
    func testUnionWithParenthesizedSubqueriesFlag() {
        // Test that the parenthesized subqueries flag does as expected, including for multiple unions
        self.db._dialect.unionFeatures = [.union, .unionAll, .parenthesizedSubqueries]
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").union(distinct: { $0.column("id").from("t2") }),
            is: "(SELECT `id` FROM `t1`) UNION (SELECT `id` FROM `t2`)"
        )
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").union(distinct: { $0.column("id").from("t2") }).union(distinct: { $0.column("id").from("t3") }),
            is: "(SELECT `id` FROM `t1`) UNION (SELECT `id` FROM `t2`) UNION (SELECT `id` FROM `t3`)"
        )
    }
    
    func testUnionChaining() {
        // Test that chaining and mixing multiple union types works
        self.db._dialect.unionFeatures = [.union, .unionAll, .intersect, .intersectAll, .except, .exceptAll, .explicitDistinct, .parenthesizedSubqueries]
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1")
                .union(distinct:     { $0.column("id").from("t2") })
                .union(all:          { $0.column("id").from("t3") })
                .intersect(distinct: { $0.column("id").from("t4") })
                .intersect(all:      { $0.column("id").from("t5") })
                .except(distinct:    { $0.column("id").from("t6") })
                .except(all:         { $0.column("id").from("t7") }),
            is: "(SELECT `id` FROM `t1`) UNION DISTINCT (SELECT `id` FROM `t2`) UNION ALL (SELECT `id` FROM `t3`) INTERSECT DISTINCT (SELECT `id` FROM `t4`) INTERSECT ALL (SELECT `id` FROM `t5`) EXCEPT DISTINCT (SELECT `id` FROM `t6`) EXCEPT ALL (SELECT `id` FROM `t7`)"
        )
    }
    
    func testOneQueryUnion() {
        // Test that having a single entry in the union just executes that entry
        XCTAssertSerialization(
            of: self.db.union { $0.column("id").from("t1") },
            is: "SELECT `id` FROM `t1`"
        )
    }
    
    func testUnionOverallModifiers() {
        // Test LIMIT, OFFSET, and ORDER BY
        self.db._dialect.unionFeatures = [.union, .unionAll, .intersect, .intersectAll, .except, .exceptAll, .parenthesizedSubqueries]
        XCTAssertSerialization(
            of: self.db.select().column("id").from("t1").union({ $0.column("id").from("t2") }).limit(3).offset(5).orderBy("id"),
            is: "(SELECT `id` FROM `t1`) UNION (SELECT `id` FROM `t2`) ORDER BY `id` ASC LIMIT 3 OFFSET 5"
        )
        
        // Test multiple ORDER BY statements
        XCTAssertSerialization(
            of: self.db.select().column("*").from("t1").union({ $0.column("*").from("t2") }).orderBy("id").orderBy("name", .descending),
            is: "(SELECT * FROM `t1`) UNION (SELECT * FROM `t2`) ORDER BY `id` ASC, `name` DESC"
        )
    }
}
