extension SQLQueryFetcher {
    /// Concurrency-aware version of ``SQLQueryFetcher/first(decodingColumn:as:)-4965m``.
    @inlinable
    public func first<D: Decodable>(decodingColumn column: String, as: D.Type) async throws -> D? {
        try await self.first()?.decode(column: column, as: D.self)
    }

    /// Concurrency-aware version of ``SQLQueryFetcher/first(decoding:prefix:keyDecodingStrategy:)-8e3pp``.
    @inlinable
    public func first<D: Decodable>(
        decoding: D.Type,
        prefix: String? = nil,
        keyDecodingStrategy: SQLRowDecoder.KeyDecodingStrategy = .useDefaultKeys
    ) async throws -> D? {
        try await self.first()?.decode(model: D.self, prefix: prefix, keyDecodingStrategy: keyDecodingStrategy)
    }

    /// Concurrency-aware version of ``SQLQueryFetcher/first(decoding:with:)-1n97m``.
    @inlinable
    public func first<D: Decodable>(decoding: D.Type, with decoder: SQLRowDecoder) async throws -> D? {
        try await self.first()?.decode(model: D.self, with: decoder)
    }

    /// Concurrency-aware version of ``SQLQueryFetcher/first(decoding:)-6gqh3``.
    @inlinable
    public func first<D: Decodable>(decoding: D.Type) async throws -> D? {
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
    
    /// Concurrency-aware version of ``SQLQueryFetcher/all(decodingColumn:as:)-197ym``.
    @inlinable
    public func all<D: Decodable>(decodingColumn column: String, as: D.Type) async throws -> [D] {
        try await self.all().map { try $0.decode(column: column, as: D.self) }
    }

    /// Concurrency-aware version of ``SQLQueryFetcher/all(decoding:prefix:keyDecodingStrategy:)-9ziys``.
    @inlinable
    public func all<D: Decodable>(
        decoding: D.Type,
        prefix: String? = nil,
        keyDecodingStrategy: SQLRowDecoder.KeyDecodingStrategy = .useDefaultKeys
    ) async throws -> [D] {
        try await self.all().map { try $0.decode(model: D.self, prefix: prefix, keyDecodingStrategy: keyDecodingStrategy) }
    }

    /// Concurrency-aware version of ``SQLQueryFetcher/all(decoding:with:)-5fc4b``.
    @inlinable
    public func all<D: Decodable>(decoding: D.Type, with decoder: SQLRowDecoder) async throws -> [D] {
        try await self.all().map { try $0.decode(model: D.self, with: decoder) }
    }

    /// Concurrency-aware version of ``SQLQueryFetcher/all(decoding:)-6q02f``.
    @inlinable
    public func all<D: Decodable>(decoding: D.Type) async throws -> [D] {
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
    public func run<D: Decodable>(
        decoding: D.Type, _ handler: @escaping @Sendable (Result<D, any Error>
    ) -> ()) async throws {
        try await self.run { row in handler(Result { try row.decode(model: D.self) }) }
    }

    /// Concurrency-aware version of ``SQLQueryFetcher/run(decoding:prefix:keyDecodingStrategy:_:)-8yslt``.
    @inlinable
    @preconcurrency
    public func run<D: Decodable>(
        decoding: D.Type,
        prefix: String? = nil,
        keyDecodingStrategy: SQLRowDecoder.KeyDecodingStrategy = .useDefaultKeys,
        _ handler: @escaping @Sendable (Result<D, any Error>) -> ()
    ) async throws {
        try await self.run { row in handler(Result { try row.decode(model: D.self, prefix: prefix, keyDecodingStrategy: keyDecodingStrategy) }) }
    }

    /// Concurrency-aware version of ``SQLQueryFetcher/run(decoding:with:_:)-4tte7``.
    @inlinable
    @preconcurrency
    public func run<D: Decodable>(
        decoding: D.Type,
        with decoder: SQLRowDecoder,
        _ handler: @escaping @Sendable (Result<D, any Error>) -> ()
    ) async throws {
        try await self.run { row in handler(Result { try row.decode(model: D.self, with: decoder) }) }
    }

    /// Concurrency-aware version of ``SQLQueryFetcher/run(_:)-542bs``.
    @inlinable
    public func run(_ handler: @escaping @Sendable (any SQLRow) -> ()) async throws -> Void {
        try await self.database.execute(sql: self.query, handler)
    }
}
