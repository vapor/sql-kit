import NIOCore

public extension SQLQueryBuilder {
    func run() async throws -> Void {
        return try await self.run().get()
    }
}
