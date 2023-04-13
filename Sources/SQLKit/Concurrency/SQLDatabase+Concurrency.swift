import NIOCore

public extension SQLDatabase {
    func execute(sql query: SQLExpression, _ onRow: @escaping (SQLRow) -> ()) async throws -> Void {
        try await self.execute(sql: query, onRow).get()
    }
}
