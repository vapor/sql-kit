import XCTest
import SQLKit

extension SQLBenchmarker {
    public func testUnions() async throws {
        try await self.testUnions_Setup()
        do {
            try await self.testUnions_union()
            try await self.testUnions_unionAll()
            try await self.testUnions_intersect()
            try await self.testUnions_intersectAll()
            try await self.testUnions_except()
            try await self.testUnions_exceptAll()
            try? await self.testUnions_Teardown()
        } catch {
            try? await self.testUnions_Teardown()
            throw error
        }
    }
    
    private struct Item: Codable {
        let id: Int
    }
    
    private func testUnions_Setup() async throws {
        try await self.database.drop(table: "union_test").ifExists()
            .run()
        try await self.database.create(table: "union_test")
            .column("id",     type: .int,  .primaryKey(autoIncrement: false), .notNull)
            .column("field1", type: .text, .notNull)
            .column("field2", type: .text)
            .run()
        try await self.database.insert(into: "union_test")
            .columns("id", "field1", "field2")
            .values(1, "a", String?.none)
            .values(2, "b", "B")
            .values(3, "c", "C")
            .run()
    }
    
    private func testUnions_Teardown() async throws {
        try await self.database.drop(table: "union_test").ifExists()
            .run()
    }
    
    private func testUnions_union() async throws {
        try await self.runTest {
            guard $0.dialect.unionFeatures.contains(.union) else {
                return
            }

            let results = try await $0.select()
                .column("id")
                .from("union_test")
                .where("field1", .equal, "a")
            .union(distinct: { $0
                .column("id")
                .from("union_test")
                .where("field1", .equal, "a")
                .orWhere("field2", .equal, "B")
            })
            .all(decoding: Item.self)
            
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results.filter { $0.id == 1 }.count, 1)
            XCTAssertEqual(results.filter { $0.id == 2 }.count, 1)
        }
    }

    private func testUnions_unionAll() async throws {
        try await self.runTest {
            guard $0.dialect.unionFeatures.contains(.unionAll) else {
                return
            }

            let results = try await $0.select()
                .column("id")
                .from("union_test")
                .where("field1", .equal, "a")
            .union(all: { $0
                .column("id")
                .from("union_test")
                .where("field1", .equal, "a")
                .orWhere("field2", .equal, "B")
            })
            .all(decoding: Item.self)
            
            XCTAssertEqual(results.count, 3)
            XCTAssertEqual(results.filter { $0.id == 1 }.count, 2)
            XCTAssertEqual(results.filter { $0.id == 2 }.count, 1)
        }
    }

    private func testUnions_intersect() async throws {
        try await self.runTest {
            guard $0.dialect.unionFeatures.contains(.intersect) else {
                return
            }

            let results = try await $0.select()
                .column("id")
                .from("union_test")
                .where("field1", .equal, "a")
            .intersect(distinct: { $0
                .column("id")
                .from("union_test")
                .where("field1", .equal, "a")
                .orWhere("field2", .equal, "B")
            })
            .all(decoding: Item.self)
            
            XCTAssertEqual(results.count, 1)
            XCTAssertEqual(results.filter { $0.id == 1 }.count, 1)
        }
    }

    private func testUnions_intersectAll() async throws {
        try await self.runTest {
            guard $0.dialect.unionFeatures.contains(.intersectAll) else {
                return
            }

            let results = try await $0.select()
                .column("id")
                .from("union_test")
                .where("field1", .equal, "a")
            .union(all: { $0
                .column("id")
                .from("union_test")
                .where("field1", .equal, "a")
            }).intersect(all: { $0
                .column("id")
                .from("union_test")
                .where("field1", .equal, "a")
                .orWhere("field2", .equal, "B")
            })
            .all(decoding: Item.self)
            
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results.filter { $0.id == 1 }.count, 2)
        }
    }

    private func testUnions_except() async throws {
        try await self.runTest {
            guard $0.dialect.unionFeatures.contains(.except) else {
                return
            }

            let results = try await $0.select()
                .column("id")
                .from("union_test")
            .union(all: { $0
                .column("id")
                .from("union_test")
                .where("field1", .equal, "c")
            }).except(distinct: { $0
                .column("id")
                .from("union_test")
                .where("field1", .equal, "a")
                .orWhere("field2", .equal, "B")
            })
            .all(decoding: Item.self)
            
            XCTAssertEqual(results.count, 1)
            XCTAssertEqual(results.filter { $0.id == 3 }.count, 1)
        }
    }

    private func testUnions_exceptAll() async throws {
        try await self.runTest {
            guard $0.dialect.unionFeatures.contains(.exceptAll) else {
                return
            }

            let results = try await $0.select()
                .column("id")
                .from("union_test")
            .union(all: { $0
                .column("id")
                .from("union_test")
                .where("field1", .equal, "c")
            }).except(all: { $0
                .column("id")
                .from("union_test")
                .where("field1", .equal, "a")
                .orWhere("field2", .equal, "B")
            })
            .all(decoding: Item.self)
            
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results.filter { $0.id == 3 }.count, 2)
        }
    }
}
