import NIOCore

public extension SQLDatabase {
    #if swift(>=5.7)
    @preconcurrency
    func execute(sql query: any SQLExpression, _ onRow: @escaping @Sendable (any SQLRow) -> ()) async throws {
        try await self.execute(sql: query, onRow).get()
    }
    #else
    func execute(sql query: any SQLExpression, _ onRow: @escaping (any SQLRow) -> ()) async throws {
        try await self.execute(sql: query, onRow).get()
    }
    #endif
}
