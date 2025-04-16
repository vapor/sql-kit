import SQLKit
import XCTest

extension SQLBenchmarker {
    public func testJSONPaths() async throws {
        try await self.runTest {
            try await $0.drop(table: "planet_metadata")
                .ifExists()
                .run()
            try await $0.create(table: "planet_metadata")
                .column("id",       type: .bigint, .primaryKey(autoIncrement: $0.dialect.supportsAutoIncrement))
                .column("metadata", type: .custom(SQLUnsafeRaw($0.dialect.name == "postgresql" ? "jsonb" : "json")))
                .run()

            // insert
            try await $0.insert(into: "planet_metadata")
                .columns("id", "metadata")
                .values(SQLLiteral.default, SQLLiteral.string(#"{"a":{"b":{"c":[1,2,3]}}}"#))
                .run()
            
            // try to extract fields
            let objectARows = try await $0.select().column(SQLNestedSubpathExpression(column: "metadata", path: ["a"]), as: "data").from("planet_metadata").all()
            let objectARow  = try XCTUnwrap(objectARows.first)
            let objectARaw  = try objectARow.decode(column: "data", as: String.self)
            let objectA     = try JSONDecoder().decode([String: [String: [Int]]].self, from: objectARaw.data(using: .utf8)!)
            
            XCTAssertEqual(objectARows.count, 1)
            XCTAssertEqual(objectA, ["b": ["c": [1, 2 ,3]]])
            
            let objectBRows = try await $0.select().column(SQLNestedSubpathExpression(column: "metadata", path: ["a", "b"]), as: "data").from("planet_metadata").all()
            let objectBRow  = try XCTUnwrap(objectBRows.first)
            let objectBRaw  = try objectBRow.decode(column: "data", as: String.self)
            let objectB     = try JSONDecoder().decode([String: [Int]].self, from: objectBRaw.data(using: .utf8)!)
            
            XCTAssertEqual(objectBRows.count, 1)
            XCTAssertEqual(objectB, ["c": [1, 2, 3]])

            let objectCRows = try await $0.select().column(SQLNestedSubpathExpression(column: "metadata", path: ["a", "b", "c"]), as: "data").from("planet_metadata").all()
            let objectCRow  = try XCTUnwrap(objectCRows.first)
            let objectCRaw  = try objectCRow.decode(column: "data", as: String.self)
            let objectC     = try JSONDecoder().decode([Int].self, from: objectCRaw.data(using: .utf8)!)
            
            XCTAssertEqual(objectCRows.count, 1)
            XCTAssertEqual(objectC, [1, 2, 3])
        }
    }
}
