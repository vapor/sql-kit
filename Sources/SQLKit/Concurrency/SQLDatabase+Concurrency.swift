import NIOCore

public extension SQLDatabase {
    func execute(sql query: any SQLExpression, _ onRow: @escaping @Sendable (any SQLRow) -> ()) async throws {
        try await self.execute(sql: query, onRow).get()
    }
}
