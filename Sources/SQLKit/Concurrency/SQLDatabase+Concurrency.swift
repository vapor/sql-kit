extension SQLDatabase {
    /// Concurrency-aware version of ``SQLDatabase/execute(sql:_:)-90wi9``.
    ///
    /// If a concrete type conforming to ``SQLDatabase`` can provide a more efficient Concurrency-based implementation
    /// than forwarding the invocation through the legacy `EventLoopFuture`-based API, it should override this method
    /// in order to do so.
    @inlinable
    public func execute(
        sql query: any SQLExpression,
        _ onRow: @escaping @Sendable (any SQLRow) -> ()
    ) async throws {
        try await self.execute(sql: query, onRow).get()
    }
}
