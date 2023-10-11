extension SQLQueryFetcher {
    /// Concurrency-aware version of ``SQLQueryFetcher/first(decoding:)-6gqh3``.
    @inlinable
    public func first<D>(decoding: D.Type) async throws -> D? where D: Decodable {
        try await self.first()?.decode(model: D.self)
    }
    
    /// Concurrency-aware version of ``SQLQueryFetcher/first()-7o93q``.
    @inlinable
    public func first() async throws -> (any SQLRow)? {
        if let partialBuilder = self as? (any SQLPartialResultBuilder & SQLQueryFetcher) {
            return try await partialBuilder.limit(1).all().first
        } else {
            return try await self.all().first
        }
    }
    
    /// Concurrency-aware version of ``SQLQueryFetcher/all(decoding:)-6q02f``.
    @inlinable
    public func all<D>(decoding: D.Type) async throws -> [D] where D: Decodable {
        try await self.all().map { try $0.decode(model: D.self) }
    }
    
    /// Concurrency-aware version of ``SQLQueryFetcher/all()-5j67e``.
    @inlinable
    public func all() async throws -> [any SQLRow] {
        let rows = RowsBox()
        try await self.run { rows.all.append($0) }
        return rows.all
    }
    
    /// Concurrency-aware version of ``SQLQueryFetcher/run(decoding:_:)-6z89k``.
    @inlinable
    public func run<D>(decoding: D.Type, _ handler: @escaping @Sendable (Result<D, any Error>) -> ()) async throws -> Void where D: Decodable {
        try await self.run { row in handler(Result { try row.decode(model: D.self) }) }
    }
    
    /// Concurrency-aware version of ``SQLQueryFetcher/run(_:)-542bs``.
    @inlinable
    public func run(_ handler: @escaping @Sendable (any SQLRow) -> ()) async throws -> Void {
        try await self.database.execute(sql: self.query, handler)
    }
}
