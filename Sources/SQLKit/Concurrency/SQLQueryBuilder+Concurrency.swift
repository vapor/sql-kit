#if compiler(>=5.5) && canImport(_Concurrency)
import NIOCore

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
public extension SQLQueryBuilder {
    func run() async throws -> Void {
        return try await self.run().get()
    }
}

#endif
