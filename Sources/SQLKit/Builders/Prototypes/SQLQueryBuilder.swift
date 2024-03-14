import class NIOCore.EventLoopFuture

/// Base definitions for builders which set up queries and execute them against a given database.
///
/// Almost all concrete builders conform to this protocol.
public protocol SQLQueryBuilder: AnyObject {
    /// Query being built.
    var query: any SQLExpression { get }
    
    /// Connection to execute query on.
    var database: any SQLDatabase { get }

    /// Execute the query on the connection, ignoring any results.
    ///
    /// Although it is a protocol requirement for historical reasons, this is considered a legacy interface
    /// thanks to its reliance on `EventLoopFuture`. Users should call ``run()-3tldd`` whenever possible.
    func run() -> EventLoopFuture<Void>
    
    /// Execute the query on the connection, ignoring any results.
    func run() async throws

}

extension SQLQueryBuilder {
    /// Execute the query associated with the builder on the builder's database, ignoring any results.
    ///
    /// See ``SQLQueryFetcher`` for methods which retrieve results from a query.
    @inlinable
    public func run() -> EventLoopFuture<Void> {
        self.database.execute(sql: self.query) { _ in }
    }

    /// Execute the query associated with the builder on the builder's database, ignoring any results.
    ///
    /// See ``SQLQueryFetcher`` for methods which retrieve results from a query.
    @inlinable
    public func run() async throws {
        try await self.database.execute(sql: self.query) { _ in }
    }
}
