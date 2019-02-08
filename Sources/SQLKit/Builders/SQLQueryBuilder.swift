import NIO

/// Builds queries and executes them on a connection.
///
///     builder.run()
///
public protocol SQLQueryBuilder: class {
    /// Query being built.
    var query: SQLExpression { get }
    
    /// Connection to execute query on.
    var database: SQLDatabase { get }
}

extension SQLQueryBuilder {
    /// Runs the query.
    ///
    ///     builder.run()
    ///
    /// - returns: A future signaling completion.
    public func run() -> EventLoopFuture<Void> {
        return self.database.sqlQuery(self.query) { _ in }
    }
}
