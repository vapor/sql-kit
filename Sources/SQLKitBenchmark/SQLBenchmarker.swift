import SQLKit
import XCTest

public final class SQLBenchmarker {
    internal let database: SQLDatabase
    
    public init(on database: SQLDatabase) {
        self.database = database
    }
    
    public func testAll() throws {
        try self.testPlanets()
        try self.testCodable()
        try self.testEnum()
        if self.database.dialect.name != "generic" {
            try self.testUpserts()
        }
    }
    
    public func run() throws {
        try self.testAll()
    }

    internal func runTest(
        _ name: String = #function,
        _ test: (SQLDatabase) throws -> ()
    ) throws {
        self.database.logger.notice("[SQLBenchmark] Running \(name)...")
        try test(self.database)
    }
}
