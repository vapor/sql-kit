extension SQLDatabase {
    /// Concurrency-aware version of ``SQLDatabase/execute(sql:_:)-90wi9``.
    public func execute(sql query: any SQLExpression, _ onRow: @escaping @Sendable (any SQLRow) -> ()) async throws {
        try await self.execute(sql: query, onRow).get()
    }
}
