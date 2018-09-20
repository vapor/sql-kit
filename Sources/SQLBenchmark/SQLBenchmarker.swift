/// Benchmarks SQL conformance.
public final class SQLBenchmarker<Connection> where
    Connection: SQLConnectable
{
    internal let conn: Connection
    
    /// Creates a new `SQLBenchmark`.
    public init(on conn: Connection) {
        self.conn = conn
    }
    
    /// Runs the SQL benchmark.
    public func run() throws {
        try testPlanets()
    }
}
