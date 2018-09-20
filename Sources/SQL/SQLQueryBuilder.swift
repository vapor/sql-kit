/// Builds queries and executes them on a connection.
///
///     builder.run()
///
public protocol SQLQueryBuilder: class {
    /// See `SQLConnection`.
    associatedtype Connectable: SQLConnectable
    
    /// Query being built.
    var query: Connectable.Connection.Query { get }
    
    /// Connection to execute query on.
    var connectable: Connectable { get }
}

extension SQLQueryBuilder {
    /// Runs the query.
    ///
    ///     builder.run()
    ///
    /// - returns: A future signaling completion.
    public func run() -> Future<Void> {
        return connectable.withSQLConnection { conn in
            return conn.query(self.query) { _ in }
        }
    }
}
