import SQLKit

/// Benchmarks SQL conformance.
public final class SQLBenchmarker {
    internal let db: SQLDatabase
    
    /// Creates a new `SQLBenchmark`.
    public init(on db: SQLDatabase) {
        self.db = db
    }
    
    /// Runs the SQL benchmark.
    public func run() throws {
        try testPlanets()
    }
}
