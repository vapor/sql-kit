import SQLKit
import XCTest

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
        self.db.outputs = [TestRow(data: [:])]
        let res1 = try await self.db.select().column("a").from("b").all()
        XCTAssertEqual(res1.count, 1)
        XCTAssertEqual(self.db.results[0], "SELECT ``a`` FROM ``b``")

        self.db.outputs = [TestRow(data: [:])]
        let res2 = try await self.db.select().column("a").from("b").all().get()
        XCTAssertEqual(res2.count, 1)
        XCTAssertEqual(self.db.results[1], "SELECT ``a`` FROM ``b``")

        self.db.outputs = [TestRow(data: [:])]
        let res3 = try await self.db.select().column("a").from("b").all(decoding: [String: String].self)
        XCTAssertEqual(res3.count, 1)
        XCTAssertEqual(self.db.results[2], "SELECT ``a`` FROM ``b``")

        self.db.outputs = [TestRow(data: [:])]
        let res4 = try await self.db.select().column("a").from("b").all(decoding: [String: String].self).get()
        XCTAssertEqual(res4.count, 1)
        XCTAssertEqual(self.db.results[3], "SELECT ``a`` FROM ``b``")

        self.db.outputs = [TestRow(data: [:])]
        let res5 = try await self.db.select().column("a").from("b").all(decoding: [String: String].self, keyDecodingStrategy: .useDefaultKeys)
        XCTAssertEqual(res5.count, 1)
        XCTAssertEqual(self.db.results[4], "SELECT ``a`` FROM ``b``")

        self.db.outputs = [TestRow(data: [:])]
        let res6 = try await self.db.select().column("a").from("b").all(decoding: [String: String].self, keyDecodingStrategy: .useDefaultKeys).get()
        XCTAssertEqual(res6.count, 1)
        XCTAssertEqual(self.db.results[5], "SELECT ``a`` FROM ``b``")

        self.db.outputs = [TestRow(data: ["a": "a"])]
        let res7 = try await self.db.select().column("a").from("b").all(decodingColumn: "a", as: String.self)
        XCTAssertEqual(res7.count, 1)
        XCTAssertEqual(self.db.results[6], "SELECT ``a`` FROM ``b``")

        self.db.outputs = [TestRow(data: ["a": "a"])]
        let res8 = try await self.db.select().column("a").from("b").all(decodingColumn: "a", as: String.self).get()
        XCTAssertEqual(res8.count, 1)
        XCTAssertEqual(self.db.results[7], "SELECT ``a`` FROM ``b``")
    }
    
    func testSQLQueryFetcherFirstMethodsAsyncAndFutures() async throws {
        let res1 = try await self.db.select().column("a").from("b").first()
        XCTAssertNil(res1)
        XCTAssertEqual(self.db.results[0], "SELECT ``a`` FROM ``b`` LIMIT 1")

        let res2 = try await self.db.select().column("a").from("b").first(decoding: [String: String].self)
        XCTAssertNil(res2)
        XCTAssertEqual(self.db.results[1], "SELECT ``a`` FROM ``b`` LIMIT 1")

        let res3 = try await self.db.select().column("a").from("b").first(decoding: [String: String].self, keyDecodingStrategy: .useDefaultKeys)
        XCTAssertNil(res3)
        XCTAssertEqual(self.db.results[2], "SELECT ``a`` FROM ``b`` LIMIT 1")

        let res4 = try await self.db.select().column("a").from("b").first(decodingColumn: "a", as: String.self)
        XCTAssertNil(res4)
        XCTAssertEqual(self.db.results[3], "SELECT ``a`` FROM ``b`` LIMIT 1")

        let res5 = try await self.db.select().column("a").from("b").first().get()
        XCTAssertNil(res5)
        XCTAssertEqual(self.db.results[4], "SELECT ``a`` FROM ``b`` LIMIT 1")

        let res6 = try await self.db.select().column("a").from("b").first(decoding: [String: String].self).get()
        XCTAssertNil(res6)
        XCTAssertEqual(self.db.results[5], "SELECT ``a`` FROM ``b`` LIMIT 1")

        let res7 = try await self.db.select().column("a").from("b").first(decoding: [String: String].self, keyDecodingStrategy: .useDefaultKeys).get()
        XCTAssertNil(res7)
        XCTAssertEqual(self.db.results[6], "SELECT ``a`` FROM ``b`` LIMIT 1")

        let res8 = try await self.db.select().column("a").from("b").first(decodingColumn: "a", as: String.self).get()
        XCTAssertNil(res8)
        XCTAssertEqual(self.db.results[7], "SELECT ``a`` FROM ``b`` LIMIT 1")
    }
}
