extension SQLQueryBuilder {
    /// Concurrency-aware version of ``SQLQueryBuilder/run()-2zws8``.
    @inlinable
    public func run() async throws -> Void {
        try await self.database.execute(sql: self.query) { _ in }
    }
}
