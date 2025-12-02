import SQLKit
import XCTest
import NIOCore
import OrderedCollections

final class AsyncSQLKitTests: XCTestCase {
    var db = TestDatabase()

    override class func setUp() {
        XCTAssert(isLoggingConfigured)
    }
    
    func testSQLDatabaseAsyncAndFutures() async throws {
        try await self.db.execute(sql: SQLRaw("TEST"), { _ in XCTFail("Should not receive results") }).get()
        XCTAssertEqual(self.db.results[0], "TEST")
        
        try await self.db.execute(sql: SQLRaw("TEST"), { _ in XCTFail("Should not receive results") })
        XCTAssertEqual(self.db.results[1], "TEST")
    }
    
    func testSQLQueryBuilderAsyncAndFutures() async throws {
        self.db.outputs = [TestRow(data: [:])]
        try await self.db.update("a").set("b", to: "c").run().get()
        XCTAssertEqual(self.db.results[0], "UPDATE ``a`` SET ``b`` = &1")

        self.db.outputs = [TestRow(data: [:])]
        try await self.db.update("a").set("b", to: "c").run()
        XCTAssertEqual(self.db.results[1], "UPDATE ``a`` SET ``b`` = &1")
    }
    
    func testSQLQueryFetcherRunMethodsAsyncAndFutures() async throws {
        try await self.db.select().column("a").from("b").run { _ in XCTFail("Should not receive results") }
        XCTAssertEqual(self.db.results[0], "SELECT ``a`` FROM ``b``")

        try await self.db.select().column("a").from("b").run { _ in XCTFail("Should not receive results") }.get()
        XCTAssertEqual(self.db.results[1], "SELECT ``a`` FROM ``b``")

        self.db.outputs = [TestRow(data: [:])]
        try await self.db.select().column("a").from("b").run { XCTAssert($0.allColumns.isEmpty) }
        XCTAssertEqual(self.db.results[2], "SELECT ``a`` FROM ``b``")

        self.db.outputs = [TestRow(data: [:])]
        try await self.db.select().column("a").from("b").run { XCTAssert($0.allColumns.isEmpty) }.get()
        XCTAssertEqual(self.db.results[3], "SELECT ``a`` FROM ``b``")

        try await self.db.select().column("a").from("b").run(decoding: [String: String].self, { _ in XCTFail("Should not receive results") })
        XCTAssertEqual(self.db.results[4], "SELECT ``a`` FROM ``b``")
        
        try await self.db.select().column("a").from("b").run(decoding: [String: String].self, { _ in XCTFail("Should not receive results") }).get()
        XCTAssertEqual(self.db.results[5], "SELECT ``a`` FROM ``b``")
        
        self.db.outputs = [TestRow(data: [:])]
        try await self.db.select().column("a").from("b").run(decoding: [String: String].self, { XCTAssertNotNil(try? $0.get()) })
        XCTAssertEqual(self.db.results[6], "SELECT ``a`` FROM ``b``")

        self.db.outputs = [TestRow(data: [:])]
        try await self.db.select().column("a").from("b").run(decoding: [String: String].self, { XCTAssertNotNil(try? $0.get()) }).get()
        XCTAssertEqual(self.db.results[7], "SELECT ``a`` FROM ``b``")

        try await self.db.select().column("a").from("b").run(decoding: [String: String].self, keyDecodingStrategy: .useDefaultKeys, { _ in XCTFail("Should not receive results") })
        XCTAssertEqual(self.db.results[8], "SELECT ``a`` FROM ``b``")

        try await self.db.select().column("a").from("b").run(decoding: [String: String].self, keyDecodingStrategy: .useDefaultKeys, { _ in XCTFail("Should not receive results") }).get()
        XCTAssertEqual(self.db.results[9], "SELECT ``a`` FROM ``b``")

        self.db.outputs = [TestRow(data: [:])]
        try await self.db.select().column("a").from("b").run(decoding: [String: String].self, keyDecodingStrategy: .useDefaultKeys, { XCTAssertNotNil(try? $0.get()) })
        XCTAssertEqual(self.db.results[10], "SELECT ``a`` FROM ``b``")

        self.db.outputs = [TestRow(data: [:])]
        try await self.db.select().column("a").from("b").run(decoding: [String: String].self, keyDecodingStrategy: .useDefaultKeys, { XCTAssertNotNil(try? $0.get()) }).get()
        XCTAssertEqual(self.db.results[11], "SELECT ``a`` FROM ``b``")
    }
    
    func testSQLQueryFetcherAllMethodsAsyncAndFutures() async throws {
        let res0 = try await self.db.select().column("a").from("b").all()
        XCTAssert(res0.isEmpty)
        XCTAssertEqual(self.db.results[0], "SELECT ``a`` FROM ``b``")

        self.db.outputs = [TestRow(data: [:])]
        let res1 = try await self.db.select().column("a").from("b").all()
        XCTAssertEqual(res1.count, 1)
        XCTAssertEqual(self.db.results[1], "SELECT ``a`` FROM ``b``")

        self.db.outputs = [TestRow(data: [:])]
        let res2 = try await self.db.select().column("a").from("b").all().get()
        XCTAssertEqual(res2.count, 1)
        XCTAssertEqual(self.db.results[2], "SELECT ``a`` FROM ``b``")

        self.db.outputs = [TestRow(data: [:])]
        let res3 = try await self.db.select().column("a").from("b").all(decoding: [String: String].self)
        XCTAssertEqual(res3.count, 1)
        XCTAssertEqual(self.db.results[3], "SELECT ``a`` FROM ``b``")

        self.db.outputs = [TestRow(data: [:])]
        let res4 = try await self.db.select().column("a").from("b").all(decoding: [String: String].self).get()
        XCTAssertEqual(res4.count, 1)
        XCTAssertEqual(self.db.results[4], "SELECT ``a`` FROM ``b``")

        self.db.outputs = [TestRow(data: [:])]
        let res5 = try await self.db.select().column("a").from("b").all(decoding: [String: String].self, keyDecodingStrategy: .useDefaultKeys)
        XCTAssertEqual(res5.count, 1)
        XCTAssertEqual(self.db.results[5], "SELECT ``a`` FROM ``b``")

        self.db.outputs = [TestRow(data: [:])]
        let res6 = try await self.db.select().column("a").from("b").all(decoding: [String: String].self, keyDecodingStrategy: .useDefaultKeys).get()
        XCTAssertEqual(res6.count, 1)
        XCTAssertEqual(self.db.results[6], "SELECT ``a`` FROM ``b``")

        self.db.outputs = [TestRow(data: ["a": "a"])]
        let res7 = try await self.db.select().column("a").from("b").all(decodingColumn: "a", as: String.self)
        XCTAssertEqual(res7.count, 1)
        XCTAssertEqual(self.db.results[7], "SELECT ``a`` FROM ``b``")

        self.db.outputs = [TestRow(data: ["a": "a"])]
        let res8 = try await self.db.select().column("a").from("b").all(decodingColumn: "a", as: String.self).get()
        XCTAssertEqual(res8.count, 1)
        XCTAssertEqual(self.db.results[8], "SELECT ``a`` FROM ``b``")
    }
    
    func testSQLQueryFetcherFirstMethodsAsyncAndFutures() async throws {
        let res0 = try await self.db.select().column("a").from("b").first()
        XCTAssertNil(res0)
        XCTAssertEqual(self.db.results[0], "SELECT ``a`` FROM ``b`` LIMIT 1")

        self.db.outputs = [TestRow(data: [:])]
        let res1 = try await self.db.select().column("a").from("b").first()
        XCTAssertNotNil(res1)
        XCTAssertEqual(self.db.results[1], "SELECT ``a`` FROM ``b`` LIMIT 1")

        self.db.outputs = [TestRow(data: [:])]
        let res2 = try await self.db.select().column("a").from("b").first(decoding: [String: String].self)
        XCTAssertNotNil(res2)
        XCTAssertEqual(self.db.results[2], "SELECT ``a`` FROM ``b`` LIMIT 1")

        self.db.outputs = [TestRow(data: [:])]
        let res3 = try await self.db.select().column("a").from("b").first(decoding: [String: String].self, keyDecodingStrategy: .useDefaultKeys)
        XCTAssertNotNil(res3)
        XCTAssertEqual(self.db.results[3], "SELECT ``a`` FROM ``b`` LIMIT 1")

        self.db.outputs = [TestRow(data: ["a": "a"])]
        let res4 = try await self.db.select().column("a").from("b").first(decodingColumn: "a", as: String.self)
        XCTAssertNotNil(res4)
        XCTAssertEqual(self.db.results[4], "SELECT ``a`` FROM ``b`` LIMIT 1")

        self.db.outputs = [TestRow(data: [:])]
        let res5 = try await self.db.select().column("a").from("b").first().get()
        XCTAssertNotNil(res5)
        XCTAssertEqual(self.db.results[5], "SELECT ``a`` FROM ``b`` LIMIT 1")

        self.db.outputs = [TestRow(data: [:])]
        let res6 = try await self.db.select().column("a").from("b").first(decoding: [String: String].self).get()
        XCTAssertNotNil(res6)
        XCTAssertEqual(self.db.results[6], "SELECT ``a`` FROM ``b`` LIMIT 1")

        self.db.outputs = [TestRow(data: [:])]
        let res7 = try await self.db.select().column("a").from("b").first(decoding: [String: String].self, keyDecodingStrategy: .useDefaultKeys).get()
        XCTAssertNotNil(res7)
        XCTAssertEqual(self.db.results[7], "SELECT ``a`` FROM ``b`` LIMIT 1")

        let res8 = try await self.db.select().column("a").from("b").first(decodingColumn: "a", as: String.self).get()
        XCTAssertNil(res8)
        XCTAssertEqual(self.db.results[8], "SELECT ``a`` FROM ``b`` LIMIT 1")
    }
}
