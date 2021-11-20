#if compiler(>=5.5) && canImport(_Concurrency)
import NIOCore

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
public extension SQLDatabase {
    func execute(sql query: SQLExpression, _ onRow: @escaping (SQLRow) -> ()) async throws -> Void {
        try await self.execute(sql: query, onRow).get()
    }
}

#endif
