import NIO

/// Builds queries and executes them on a connection.
///
///     builder.run()
///
public protocol SQLQueryBuilder: class {
    /// See `SQLConnection`.
    associatedtype Database: SQLDatabase
    
    /// Query being built.
    var query: Database.Query { get }
    
    /// Connection to execute query on.
    var database: Database { get }
}

extension SQLQueryBuilder {
    /// Runs the query.
    ///
    ///     builder.run()
    ///
    /// - returns: A future signaling completion.
    public func run() -> EventLoopFuture<Void> {
        return self.database.execute(self.query) { _ in }
    }
}
