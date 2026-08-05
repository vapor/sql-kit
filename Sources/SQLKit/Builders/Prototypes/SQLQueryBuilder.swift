/// Base definitions for builders which set up queries and execute them against a given database.
///
/// Almost all concrete builders conform to this protocol.
public protocol SQLQueryBuilder: AnyObject {
    /// Query being built.
    var query: any SQLExpression { get }
    
    /// Connection to execute query on.
    var database: any SQLDatabase { get }
    
    /// Execute the query on the connection, ignoring any results.
    func run() async throws

}

extension SQLQueryBuilder {
    /// Execute the query associated with the builder on the builder's database, ignoring any results.
    ///
    /// See ``SQLQueryFetcher`` for methods which retrieve results from a query.
    @inlinable
    public func run() async throws {
        try await self.database.execute(sql: self.query) { _ in }
    }
}
