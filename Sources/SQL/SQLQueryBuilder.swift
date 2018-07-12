/// Builds queries and executes them on a connection.
///
///     builder.run()
///
public protocol SQLQueryBuilder: class {
    /// See `SQLConnection`.
    associatedtype Connection: SQLConnection
    
    /// Query being built.
    var query: Connection.Query { get }
    
    /// Connection to execute query on.
    var connection: Connection { get }
}

extension SQLQueryBuilder {
    /// Runs the query.
    ///
    ///     builder.run()
    ///
    /// - returns: A future signaling completion.
    public func run() -> Future<Void> {
        return connection.query(query) { _ in }
    }
}
