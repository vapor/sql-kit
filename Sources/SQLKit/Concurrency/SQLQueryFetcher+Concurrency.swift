import NIOCore

public extension SQLQueryFetcher {
    func first<D>(decoding: D.Type) async throws -> D? where D: Decodable {
        try await self.first(decoding: D.self).get()
    }
    
    func first() async throws -> (any SQLRow)? {
        try await self.first().get()
    }
    
    func all<D>(decoding: D.Type) async throws -> [D] where D: Decodable {
        try await self.all(decoding: D.self).get()
    }
    
    func all() async throws -> [any SQLRow] {
        try await self.all().get()
    }
    
    func run<D>(decoding: D.Type, _ handler: @escaping @Sendable (Result<D, Error>) -> ()) async throws -> Void where D: Decodable {
        try await self.run(decoding: D.self, handler).get()
    }
    
    func run(_ handler: @escaping @Sendable (any SQLRow) -> ()) async throws -> Void {
        try await self.run(handler).get()
    }
}
