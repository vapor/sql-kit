import XCTest
import SQLKit

extension SQLBenchmarker {
    public func testUnions() throws {
        try self.testUnions_Setup()
        defer { try? self.testUnions_Teardown() }
        
        try self.testUnions_union()
        try self.testUnions_unionAll()
        try self.testUnions_intersect()
        try self.testUnions_intersectAll()
        try self.testUnions_except()
        try self.testUnions_exceptAll()
    }
    
    private struct Item: Codable {
        let id: Int
    }
    
    private func testUnions_Setup() throws {
        try self.database.drop(table: "union_test").ifExists().run().wait()
        try self.database.create(table: "union_test")
            .column("id", type: .int, .primaryKey(autoIncrement: false), .notNull)
            .column("field1", type: .text, .notNull)
            .column("field2", type: .text)
            .run().wait()
        try self.database.insert(into: "union_test")
            .columns("id", "field1", "field2")
            .values(1, "a", String?.none)
            .values(2, "b", "B")
            .values(3, "c", "C")
            .run().wait()
    }
    
    private func testUnions_Teardown() throws {
        try self.database.drop(table: "union_test").ifExists().run().wait()
    }
    
    private func testUnions_union() throws {
        try self.runTest {
            guard $0.dialect.unionFeatures.contains(.union) else {
                return
            }

            let results = try $0.select()
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
            .wait()
            
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results.filter { $0.id == 1 }.count, 1)
            XCTAssertEqual(results.filter { $0.id == 2 }.count, 1)
        }
    }

    private func testUnions_unionAll() throws {
        try self.runTest {
            guard $0.dialect.unionFeatures.contains(.unionAll) else {
                return
            }

            let results = try $0.select()
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
            .wait()
            
            XCTAssertEqual(results.count, 3)
            XCTAssertEqual(results.filter { $0.id == 1 }.count, 2)
            XCTAssertEqual(results.filter { $0.id == 2 }.count, 1)
        }
    }

    private func testUnions_intersect() throws {
        try self.runTest {
            guard $0.dialect.unionFeatures.contains(.intersect) else {
                return
            }

            let results = try $0.select()
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
            .wait()
            
            XCTAssertEqual(results.count, 1)
            XCTAssertEqual(results.filter { $0.id == 1 }.count, 1)
        }
    }

    private func testUnions_intersectAll() throws {
        try self.runTest {
            guard $0.dialect.unionFeatures.contains(.intersectAll) else {
                return
            }

            let results = try $0.select()
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
            .wait()
            
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results.filter { $0.id == 1 }.count, 2)
        }
    }

    private func testUnions_except() throws {
        try self.runTest {
            guard $0.dialect.unionFeatures.contains(.except) else {
                return
            }

            let results = try $0.select()
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
            .wait()
            
            XCTAssertEqual(results.count, 1)
            XCTAssertEqual(results.filter { $0.id == 3 }.count, 1)
        }
    }

    private func testUnions_exceptAll() throws {
        try self.runTest {
            guard $0.dialect.unionFeatures.contains(.exceptAll) else {
                return
            }

            let results = try $0.select()
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
            .wait()
            
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results.filter { $0.id == 3 }.count, 2)
        }
    }

}
