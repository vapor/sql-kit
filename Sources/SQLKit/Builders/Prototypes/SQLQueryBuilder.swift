import NIOCore

/// Base definitions for builders which set up queries and executes them on a connection.
public protocol SQLQueryBuilder: AnyObject {
    /// Query being built.
    var query: any SQLExpression { get }
    
    /// Connection to execute query on.
    var database: any SQLDatabase { get }

    /// Execute the query on the connection, ignoring any results.
    func run() -> EventLoopFuture<Void>
}

extension SQLQueryBuilder {
    /// Execute the query on the connection, ignoring any results.
    @inlinable
    public func run() -> EventLoopFuture<Void> {
        self.database.execute(sql: self.query) { _ in }
    }
}
