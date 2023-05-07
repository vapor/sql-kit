import NIOCore

public extension SQLQueryBuilder {
    func run() async throws -> Void {
        try await self.run().get()
    }
}
