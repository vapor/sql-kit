import SQLKit
import Testing

@Suite("UNION tests")
struct UnionTests {
    // MARK: Top-level unions

    @Test("UNION")
    func union_UNION() throws {
        let db = TestDatabase()

        // Check that queries are explicitly malformed without the feature flags
        db._dialect.unionFeatures = []

        try expectSerialization(
            of: db.select().column("id").from("t1").union(distinct: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` SELECT ``id`` FROM ``t2``"
        )
        try expectSerialization(
            of: db.select().column("id").from("t1").union(all: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` SELECT ``id`` FROM ``t2``"
        )

        // Test that queries are correctly formed with the feature flags
        db._dialect.unionFeatures.formUnion([.union, .unionAll])

        try expectSerialization(
            of: db.select().column("id").from("t1").union(distinct: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` UNION SELECT ``id`` FROM ``t2``"
        )
        try expectSerialization(
            of: db.select().column("id").from("t1").union(all: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` UNION ALL SELECT ``id`` FROM ``t2``"
        )

        // Test that the explicit distinct flag is respected
        db._dialect.unionFeatures.insert(.explicitDistinct)
        try expectSerialization(
            of: db.select().column("id").from("t1").union(distinct: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` UNION DISTINCT SELECT ``id`` FROM ``t2``"
        )
    }

    @Test("INTERSECT")
    func union_INTERSECT() throws {
        let db = TestDatabase()

        // Check that queries are explicitly malformed without the feature flags
        db._dialect.unionFeatures = []

        try expectSerialization(
            of: db.select().column("id").from("t1").intersect(distinct: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` SELECT ``id`` FROM ``t2``"
        )
        try expectSerialization(
            of: db.select().column("id").from("t1").intersect(all: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` SELECT ``id`` FROM ``t2``"
        )

        // Test that queries are correctly formed with the feature flags
        db._dialect.unionFeatures.formUnion([.intersect, .intersectAll])

        try expectSerialization(
            of: db.select().column("id").from("t1").intersect(distinct: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` INTERSECT SELECT ``id`` FROM ``t2``"
        )
        try expectSerialization(
            of: db.select().column("id").from("t1").intersect(all: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` INTERSECT ALL SELECT ``id`` FROM ``t2``"
        )

        // Test that the explicit distinct flag is respected
        db._dialect.unionFeatures.insert(.explicitDistinct)

        try expectSerialization(
            of: db.select().column("id").from("t1").intersect(distinct: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` INTERSECT DISTINCT SELECT ``id`` FROM ``t2``"
        )
    }

    @Test("EXCEPT")
    func union_EXCEPT() throws {
        let db = TestDatabase()

        // Check that queries are explicitly malformed without the feature flags
        db._dialect.unionFeatures = []

        try expectSerialization(
            of: db.select().column("id").from("t1").except(distinct: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` SELECT ``id`` FROM ``t2``"
        )
        try expectSerialization(
            of: db.select().column("id").from("t1").except(all: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` SELECT ``id`` FROM ``t2``"
        )

        // Test that queries are correctly formed with the feature flags
        db._dialect.unionFeatures.formUnion([.except, .exceptAll])

        try expectSerialization(
            of: db.select().column("id").from("t1").except(distinct: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` EXCEPT SELECT ``id`` FROM ``t2``"
        )
        try expectSerialization(
            of: db.select().column("id").from("t1").except(all: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` EXCEPT ALL SELECT ``id`` FROM ``t2``"
        )

        // Test that the explicit distinct flag is respected
        db._dialect.unionFeatures.insert(.explicitDistinct)

        try expectSerialization(
            of: db.select().column("id").from("t1").except(distinct: { $0.column("id").from("t2") }),
            is: "SELECT ``id`` FROM ``t1`` EXCEPT DISTINCT SELECT ``id`` FROM ``t2``"
        )
    }

    @Test("union with parenthesized subqueries flag")
    func unionWithParenthesizedSubqueriesFlag() throws {
        let db = TestDatabase()

        // Test that the parenthesized subqueries flag does as expected, including for multiple unions
        db._dialect.unionFeatures = [.union, .unionAll, .parenthesizedSubqueries]
        try expectSerialization(
            of: db.select().column("id").from("t1").union(distinct: { $0.column("id").from("t2") }),
            is: "(SELECT ``id`` FROM ``t1``) UNION (SELECT ``id`` FROM ``t2``)"
        )
        try expectSerialization(
            of: db.select().column("id").from("t1").union(distinct: { $0.column("id").from("t2") }).union(distinct: { $0.column("id").from("t3") }),
            is: "(SELECT ``id`` FROM ``t1``) UNION (SELECT ``id`` FROM ``t2``) UNION (SELECT ``id`` FROM ``t3``)"
        )
    }

    @Test("union chaining")
    func unionChaining() throws {
        let db = TestDatabase()

        // Test that chaining and mixing multiple union types works
        db._dialect.unionFeatures = [.union, .unionAll, .intersect, .intersectAll, .except, .exceptAll, .explicitDistinct, .parenthesizedSubqueries]
        try expectSerialization(
            of: db.select().column("id").from("t1")
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

    @Test("one-query union")
    func oneQueryUnion() throws {
        let db = TestDatabase()

        // Test that having a single entry in the union just executes that entry
        try expectSerialization(
            of: db.union { $0.column("id").from("t1") },
            is: "SELECT ``id`` FROM ``t1``"
        )
    }

    @Test("union subtypes from SELECT")
    func unionSubtypesFromSelect() throws {
        let db = TestDatabase()

        db._dialect.unionFeatures = [.union, .unionAll, .intersect, .intersectAll, .except, .exceptAll, .parenthesizedSubqueries]
        try expectSerialization(
            of: db.select().column("id").from("t1").union({ $0.column("id").from("t2") }),
            is: "(SELECT ``id`` FROM ``t1``) UNION (SELECT ``id`` FROM ``t2``)"
        )

        try expectSerialization(
            of: db.select().column("id").from("t1").intersect({ $0.column("id").from("t2") }),
            is: "(SELECT ``id`` FROM ``t1``) INTERSECT (SELECT ``id`` FROM ``t2``)"
        )

        try expectSerialization(
            of: db.select().column("id").from("t1").except({ $0.column("id").from("t2") }),
            is: "(SELECT ``id`` FROM ``t1``) EXCEPT (SELECT ``id`` FROM ``t2``)"
        )
    }

    @Test("union overall modifiers")
    func unionOverallModifiers() throws {
        let db = TestDatabase()

        // Test LIMIT and OFFSET
        db._dialect.unionFeatures = [.union, .unionAll, .intersect, .intersectAll, .except, .exceptAll, .parenthesizedSubqueries]
        try expectSerialization(
            of: db.select().column("id").from("t1").union({ $0.column("id").from("t2") }).limit(3).offset(5),
            is: "(SELECT ``id`` FROM ``t1``) UNION (SELECT ``id`` FROM ``t2``) LIMIT 3 OFFSET 5"
        )

        // Cover the property getters
        let builder = db.union({ $0.where(SQLLiteral.boolean(true)) }).limit(1).offset(2)
        #expect(builder.limit == 1)
        #expect(builder.offset == 2)

        // Test multiple ORDER BY statements
        try expectSerialization(
            of: db.select().column("*").from("t1").union({ $0.column("*").from("t2") }).orderBy("id").orderBy("name", .descending),
            is: "(SELECT * FROM ``t1``) UNION (SELECT * FROM ``t2``) ORDER BY ``id`` ASC, ``name`` DESC"
        )
    }

    @Test("union add method")
    func unionAddMethod() throws {
        let db = TestDatabase()
        var query = SQLUnion(initialQuery: db.select().columns("*").select)

        query.add(db.select().columns("*").select, all: true)
        query.add(db.select().columns("*").select, all: false)

        db._dialect.unionFeatures = []
        try expectSerialization(of: db.raw("\(query)"), is: "SELECT * SELECT * SELECT *")

        db._dialect.unionFeatures = [.union, .unionAll]
        try expectSerialization(of: db.raw("\(query)"), is: "SELECT * UNION ALL SELECT * UNION SELECT *")
    }

    // MARK: Subquery unions

    @Test("UNION in subquery")
    func unionSubquery_UNION() throws {
        let db = TestDatabase()

        // Check that queries are explicitly malformed without the feature flags
        db._dialect.unionFeatures = []

        try expectSerialization(
            of: db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .union(distinct: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` SELECT ``id`` FROM ``t3``)"
        )
        try expectSerialization(
            of: db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .union(all: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` SELECT ``id`` FROM ``t3``)"
        )

        // Test that queries are correctly formed with the feature flags
        db._dialect.unionFeatures.formUnion([.union, .unionAll])

        try expectSerialization(
            of: db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .union(distinct: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` UNION SELECT ``id`` FROM ``t3``)"
        )
        try expectSerialization(
            of: db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .union(all: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` UNION ALL SELECT ``id`` FROM ``t3``)"
        )

        // Test that the explicit distinct flag is respected
        db._dialect.unionFeatures.insert(.explicitDistinct)
        try expectSerialization(
            of: db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .union(distinct: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` UNION DISTINCT SELECT ``id`` FROM ``t3``)"
        )
    }

    @Test("INTERSECT in subquery")
    func unionSubquery_INTERSECT() throws {
        let db = TestDatabase()

        // Check that queries are explicitly malformed without the feature flags
        db._dialect.unionFeatures = []

        try expectSerialization(
            of: db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .intersect(distinct: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` SELECT ``id`` FROM ``t3``)"
        )
        try expectSerialization(
            of: db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .intersect(all: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` SELECT ``id`` FROM ``t3``)"
        )

        // Test that queries are correctly formed with the feature flags
        db._dialect.unionFeatures.formUnion([.intersect, .intersectAll])

        try expectSerialization(
            of: db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .intersect(distinct: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` INTERSECT SELECT ``id`` FROM ``t3``)"
        )
        try expectSerialization(
            of: db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .intersect(all: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` INTERSECT ALL SELECT ``id`` FROM ``t3``)"
        )

        // Test that the explicit distinct flag is respected
        db._dialect.unionFeatures.insert(.explicitDistinct)

        try expectSerialization(
            of: db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .intersect(distinct: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` INTERSECT DISTINCT SELECT ``id`` FROM ``t3``)"
        )
    }

    @Test("EXCEPT in subquery")
    func unionSubquery_EXCEPT() throws {
        let db = TestDatabase()

        // Check that queries are explicitly malformed without the feature flags
        db._dialect.unionFeatures = []

        try expectSerialization(
            of: db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .except(distinct: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` SELECT ``id`` FROM ``t3``)"
        )
        try expectSerialization(
            of: db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .except(all: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` SELECT ``id`` FROM ``t3``)"
        )

        // Test that queries are correctly formed with the feature flags
        db._dialect.unionFeatures.formUnion([.except, .exceptAll])

        try expectSerialization(
            of: db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .except(distinct: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` EXCEPT SELECT ``id`` FROM ``t3``)"
        )
        try expectSerialization(
            of: db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .except(all: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` EXCEPT ALL SELECT ``id`` FROM ``t3``)"
        )

        // Test that the explicit distinct flag is respected
        db._dialect.unionFeatures.insert(.explicitDistinct)

        try expectSerialization(
            of: db.select().column("id").from("t1").where("foo", .notIn, SQLSubquery
                .union { $0 .column("id").from("t2") }
                .except(distinct: { $0.column("id").from("t3") })
                .finish()
            ),
            is: "SELECT ``id`` FROM ``t1`` WHERE ``foo`` NOT IN (SELECT ``id`` FROM ``t2`` EXCEPT DISTINCT SELECT ``id`` FROM ``t3``)"
        )
    }

}
