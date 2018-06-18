/// Benchmarks SQL conformance.
public final class SQLBenchmarker<Connection> where
    Connection: DatabaseQueryable, Connection.Query: SQLQuery, Connection.Output == Connection.Query.RowDecoder.Row
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
