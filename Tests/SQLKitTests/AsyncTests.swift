import NIOCore
import OrderedCollections
import SQLKit
import Testing

@Suite("Async tests")
struct AsyncTests {
    @Test("SQLDatabase async and futures")
    func SQLDatabaseAsyncAndFutures() async throws {
        let db = TestDatabase()

        try await db.execute(sql: SQLRaw("TEST"), { _ in Issue.record("Should not receive results") }).get()
        #expect(db.results[0] == "TEST")

        try await db.execute(sql: SQLRaw("TEST"), { _ in Issue.record("Should not receive results") })
        #expect(db.results[1] == "TEST")
    }
    
    @Test("SQLQueryBuilder async and futures")
    func SQLQueryBuilderAsyncAndFutures() async throws {
        let db = TestDatabase()

        db.outputs = [TestRow(data: [:])]
        try await db.update("a").set("b", to: "c").run().get()
        #expect(db.results[0] == "UPDATE ``a`` SET ``b`` = &1")

        db.outputs = [TestRow(data: [:])]
        try await db.update("a").set("b", to: "c").run()
        #expect(db.results[1] == "UPDATE ``a`` SET ``b`` = &1")
    }
    
    @Test("SQLQueryFetcher run methods async and futures")
    func SQLQueryFetcherRunMethodsAsyncAndFutures() async throws {
        let db = TestDatabase()

        try await db.select().column("a").from("b").run { _ in Issue.record("Should not receive results") }
        #expect(db.results[0] == "SELECT ``a`` FROM ``b``")

        try await db.select().column("a").from("b").run { _ in Issue.record("Should not receive results") }.get()
        #expect(db.results[1] == "SELECT ``a`` FROM ``b``")

        db.outputs = [TestRow(data: [:])]
        try await db.select().column("a").from("b").run { #expect($0.allColumns.isEmpty) }
        #expect(db.results[2] == "SELECT ``a`` FROM ``b``")

        db.outputs = [TestRow(data: [:])]
        try await db.select().column("a").from("b").run { #expect($0.allColumns.isEmpty) }.get()
        #expect(db.results[3] == "SELECT ``a`` FROM ``b``")

        try await db.select().column("a").from("b").run(decoding: [String: String].self, { _ in Issue.record("Should not receive results") })
        #expect(db.results[4] == "SELECT ``a`` FROM ``b``")
        
        try await db.select().column("a").from("b").run(decoding: [String: String].self, { _ in Issue.record("Should not receive results") }).get()
        #expect(db.results[5] == "SELECT ``a`` FROM ``b``")
        
        db.outputs = [TestRow(data: [:])]
        try await db.select().column("a").from("b").run(decoding: [String: String].self, { #expect((try? $0.get()) != nil) })
        #expect(db.results[6] == "SELECT ``a`` FROM ``b``")

        db.outputs = [TestRow(data: [:])]
        try await db.select().column("a").from("b").run(decoding: [String: String].self, { #expect((try? $0.get()) != nil) }).get()
        #expect(db.results[7] == "SELECT ``a`` FROM ``b``")

        try await db.select().column("a").from("b").run(decoding: [String: String].self, keyDecodingStrategy: .useDefaultKeys, { _ in Issue.record("Should not receive results") })
        #expect(db.results[8] == "SELECT ``a`` FROM ``b``")

        try await db.select().column("a").from("b").run(decoding: [String: String].self, keyDecodingStrategy: .useDefaultKeys, { _ in Issue.record("Should not receive results") }).get()
        #expect(db.results[9] == "SELECT ``a`` FROM ``b``")

        db.outputs = [TestRow(data: [:])]
        try await db.select().column("a").from("b").run(decoding: [String: String].self, keyDecodingStrategy: .useDefaultKeys, { #expect((try? $0.get()) != nil) })
        #expect(db.results[10] == "SELECT ``a`` FROM ``b``")

        db.outputs = [TestRow(data: [:])]
        try await db.select().column("a").from("b").run(decoding: [String: String].self, keyDecodingStrategy: .useDefaultKeys, { #expect((try? $0.get()) != nil) }).get()
        #expect(db.results[11] == "SELECT ``a`` FROM ``b``")
    }
    
    @Test("SQLQueryFetcher all methods async and futures")
    func SQLQueryFetcherAllMethodsAsyncAndFutures() async throws {
        let db = TestDatabase()

        let res0 = try await db.select().column("a").from("b").all()
        #expect(res0.isEmpty)
        #expect(db.results[0] == "SELECT ``a`` FROM ``b``")

        db.outputs = [TestRow(data: [:])]
        let res1 = try await db.select().column("a").from("b").all()
        #expect(res1.count == 1)
        #expect(db.results[1] == "SELECT ``a`` FROM ``b``")

        db.outputs = [TestRow(data: [:])]
        let res2 = try await db.select().column("a").from("b").all().get()
        #expect(res2.count == 1)
        #expect(db.results[2] == "SELECT ``a`` FROM ``b``")

        db.outputs = [TestRow(data: [:])]
        let res3 = try await db.select().column("a").from("b").all(decoding: [String: String].self)
        #expect(res3.count == 1)
        #expect(db.results[3] == "SELECT ``a`` FROM ``b``")

        db.outputs = [TestRow(data: [:])]
        let res4 = try await db.select().column("a").from("b").all(decoding: [String: String].self).get()
        #expect(res4.count == 1)
        #expect(db.results[4] == "SELECT ``a`` FROM ``b``")

        db.outputs = [TestRow(data: [:])]
        let res5 = try await db.select().column("a").from("b").all(decoding: [String: String].self, keyDecodingStrategy: .useDefaultKeys)
        #expect(res5.count == 1)
        #expect(db.results[5] == "SELECT ``a`` FROM ``b``")

        db.outputs = [TestRow(data: [:])]
        let res6 = try await db.select().column("a").from("b").all(decoding: [String: String].self, keyDecodingStrategy: .useDefaultKeys).get()
        #expect(res6.count == 1)
        #expect(db.results[6] == "SELECT ``a`` FROM ``b``")

        db.outputs = [TestRow(data: ["a": "a"])]
        let res7 = try await db.select().column("a").from("b").all(decodingColumn: "a", as: String.self)
        #expect(res7.count == 1)
        #expect(db.results[7] == "SELECT ``a`` FROM ``b``")

        db.outputs = [TestRow(data: ["a": "a"])]
        let res8 = try await db.select().column("a").from("b").all(decodingColumn: "a", as: String.self).get()
        #expect(res8.count == 1)
        #expect(db.results[8] == "SELECT ``a`` FROM ``b``")
    }
    
    @Test("SQLQueryFetcher first methods async and futures")
    func SQLQueryFetcherFirstMethodsAsyncAndFutures() async throws {
        let db = TestDatabase()

        let res0 = try await db.select().column("a").from("b").first()
        #expect(res0 == nil)
        #expect(db.results[0] == "SELECT ``a`` FROM ``b`` LIMIT 1")

        db.outputs = [TestRow(data: [:])]
        let res1 = try await db.select().column("a").from("b").first()
        #expect(res1 != nil)
        #expect(db.results[1] == "SELECT ``a`` FROM ``b`` LIMIT 1")

        db.outputs = [TestRow(data: [:])]
        let res2 = try await db.select().column("a").from("b").first(decoding: [String: String].self)
        #expect(res2 != nil)
        #expect(db.results[2] == "SELECT ``a`` FROM ``b`` LIMIT 1")

        db.outputs = [TestRow(data: [:])]
        let res3 = try await db.select().column("a").from("b").first(decoding: [String: String].self, keyDecodingStrategy: .useDefaultKeys)
        #expect(res3 != nil)
        #expect(db.results[3] == "SELECT ``a`` FROM ``b`` LIMIT 1")

        db.outputs = [TestRow(data: ["a": "a"])]
        let res4 = try await db.select().column("a").from("b").first(decodingColumn: "a", as: String.self)
        #expect(res4 != nil)
        #expect(db.results[4] == "SELECT ``a`` FROM ``b`` LIMIT 1")

        db.outputs = [TestRow(data: [:])]
        let res5 = try await db.select().column("a").from("b").first().get()
        #expect(res5 != nil)
        #expect(db.results[5] == "SELECT ``a`` FROM ``b`` LIMIT 1")

        db.outputs = [TestRow(data: [:])]
        let res6 = try await db.select().column("a").from("b").first(decoding: [String: String].self).get()
        #expect(res6 != nil)
        #expect(db.results[6] == "SELECT ``a`` FROM ``b`` LIMIT 1")

        db.outputs = [TestRow(data: [:])]
        let res7 = try await db.select().column("a").from("b").first(decoding: [String: String].self, keyDecodingStrategy: .useDefaultKeys).get()
        #expect(res7 != nil)
        #expect(db.results[7] == "SELECT ``a`` FROM ``b`` LIMIT 1")

        let res8 = try await db.select().column("a").from("b").first(decodingColumn: "a", as: String.self).get()
        #expect(res8 == nil)
        #expect(db.results[8] == "SELECT ``a`` FROM ``b`` LIMIT 1")
    }
}
