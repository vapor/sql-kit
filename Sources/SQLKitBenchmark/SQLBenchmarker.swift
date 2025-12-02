import Logging
import NIOCore
import SQLKit
import XCTest

public final class SQLBenchmarker: Sendable {
    let database: any SQLDatabase
    
    public init(on database: any SQLDatabase) {
        self.database = database
    }
    
    public func runAllTests() async throws {
        try await self.testPlanets()
        try await self.testCodable()
        try await self.testEnum()
        if self.database.dialect.name != "generic" {
            try await self.testUpserts()
            try await self.testUnions()
            try await self.testJSONPaths()
        }
    }
    
    @available(*, deprecated, renamed: "runAllTests()", message: "Use `runAllTests()` instead.")
    public func testAll() throws {
        try database.eventLoop.makeFutureWithTask { try await self.runAllTests() }.wait()
    }
    
    @available(*, deprecated, renamed: "runAllTests()", message: "Use `runAllTests()` instead.")
    public func run() throws {
        try self.testAll()
    }
    
    func runTest(
        _ name: String = #function,
        _ test: (any SQLDatabase) async throws -> ()
    ) async rethrows {
        self.database.logger.notice("[SQLBenchmark] Running \(name)...")
        try await test(self.database)
    }
}

func XCTAssertEqualAsync<T>(
    _ expression1: @autoclosure () async throws -> T,
    _ expression2: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath, line: UInt = #line
) async where T: Equatable {
    do {
        let expr1 = try await expression1(), expr2 = try await expression2()
        return XCTAssertEqual(expr1, expr2, message(), file: file, line: line)
    } catch {
        return XCTAssertEqual(try { () -> Bool in throw error }(), false, message(), file: file, line: line)
    }
}

func XCTAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath, line: UInt = #line,
    _ callback: (any Error) -> Void = { _ in }
) async {
    do {
        _ = try await expression()
        XCTAssertThrowsError({}(), message(), file: file, line: line, callback)
    } catch {
        XCTAssertThrowsError(try { throw error }(), message(), file: file, line: line, callback)
    }
}

func XCTAssertNoThrowAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath, line: UInt = #line
) async {
    do {
        _ = try await expression()
    } catch {
        XCTAssertNoThrow(try { throw error }(), message(), file: file, line: line)
    }
}
