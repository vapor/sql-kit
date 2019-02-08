import SQLKit

/// Benchmarks SQL conformance.
public final class SQLBenchmarker<Database> where
    Database: SQLDatabase
{
    internal let db: Database
    
    /// Creates a new `SQLBenchmark`.
    public init(on db: Database) {
        self.db = db
    }
    
    /// Runs the SQL benchmark.
    public func run() throws {
        try testPlanets()
    }
}
