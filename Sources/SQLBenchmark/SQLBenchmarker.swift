/// Benchmarks SQL conformance.
public final class SQLBenchmarker<Connectable> where
    Connectable: SQLConnectable
{
    internal let conn: Connectable
    
    /// Creates a new `SQLBenchmark`.
    public init(on conn: Connectable) {
        self.conn = conn
    }
    
    /// Runs the SQL benchmark.
    public func run() throws {
        try testPlanets()
    }
}
