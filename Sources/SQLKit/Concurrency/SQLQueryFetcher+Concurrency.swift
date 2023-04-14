import NIOCore

public extension SQLQueryFetcher {
    func first<D>(decoding: D.Type) async throws -> D? where D: Decodable {
        return try await self.first(decoding: D.self).get()
    }
    
    func first() async throws -> SQLRow? {
        return try await self.first().get()
    }
    
    func all<D>(decoding: D.Type) async throws -> [D] where D: Decodable {
        return try await self.all(decoding: D.self).get()
    }
    
    func all() async throws -> [SQLRow] {
        return try await self.all().get()
    }
    
    func run<D>(decoding: D.Type, _ handler: @escaping (Result<D, Error>) -> ()) async throws -> Void where D: Decodable {
        return try await self.run(decoding: D.self, handler).get()
    }
    
    func run(_ handler: @escaping (SQLRow) -> ()) async throws -> Void {
        return try await self.run(handler).get()
    }
}
