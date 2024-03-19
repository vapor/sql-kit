import class NIOCore.EventLoopFuture

/// Common definitions for ``SQLQueryBuilder``s which support retrieving result rows.
public protocol SQLQueryFetcher: SQLQueryBuilder {}

// MARK: - First (EventLoopFuture)

extension SQLQueryFetcher {
    /// Returns the named column from the first output row, if any, decoded as a given type.
    ///
    /// - Parameters:
    ///   - column: The name of the column to decode.
    ///   - type: The type of the desired value.
    /// - Returns: A future containing the decoded value, if any.
    @inlinable
    public func first<D: Decodable>(decodingColumn column: String, as type: D.Type) -> EventLoopFuture<D?> {
        self.first().flatMapThrowing { try $0?.decode(column: column, as: D.self) }
    }

    /// Using a default-configured ``SQLRowDecoder``, returns the first output row, if any, decoded as a given type.
    ///
    /// - Parameter type: The type of the desired value.
    /// - Returns: A future containing the decoded value, if any.
    @inlinable
    public func first<D: Decodable>(decoding type: D.Type) -> EventLoopFuture<D?> {
        self.first(decoding: D.self, with: .init())
    }

    /// Configure a new ``SQLRowDecoder`` as specified and use it to decode and return the first output row, if any,
    /// as a given type.
    /// 
    /// - Parameters:
    ///   - type: The type of the desired value.
    ///   - prefix: See ``SQLRowDecoder/prefix``.
    ///   - keyDecodingStrategy: See ``SQLRowDecoder/keyDecodingStrategy-swift.property``.
    ///   - userInfo: See ``SQLRowDecoder/userInfo``.
    /// - Returns: A future containing the decoded value, if any.
    @inlinable
    public func first<D: Decodable>(
        decoding type: D.Type,
        prefix: String? = nil,
        keyDecodingStrategy: SQLRowDecoder.KeyDecodingStrategy = .useDefaultKeys,
        userInfo: [CodingUserInfoKey: any Sendable] = [:]
    ) -> EventLoopFuture<D?> {
        self.first(decoding: D.self, with: .init(prefix: prefix, keyDecodingStrategy: keyDecodingStrategy, userInfo: userInfo))
    }

    /// Using the given ``SQLRowDecoder``, returns the first output row, if any, decoded as a given type.
    ///
    /// - Parameters:
    ///   - type: The type of the desired value.
    ///   - decoder: A configured ``SQLRowDecoder`` to use.
    /// - Returns: A future containing the decoded value, if any.
    @inlinable
    public func first<D: Decodable>(decoding type: D.Type, with decoder: SQLRowDecoder) -> EventLoopFuture<D?> {
        self.first().flatMapThrowing { try $0?.decode(model: D.self, with: decoder) }
    }

    /// Returns the first output row, if any.
    /// 
    /// If `self` conforms to ``SQLPartialResultBuilder``, ``SQLPartialResultBuilder/limit(_:)`` is used to avoid
    /// loading more rows than necessary from the database.
    ///
    /// - Returns: A future containing the first output row, if any.
    @inlinable
    public func first() -> EventLoopFuture<(any SQLRow)?> {
        (self as? any SQLPartialResultBuilder)?.limit(1)
        return self.all().map(\.first)
    }
}

// MARK: - First (async)

extension SQLQueryFetcher {
    /// Returns the named column from the first output row, if any, decoded as a given type.
    ///
    /// - Parameters:
    ///   - column: The name of the column to decode.
    ///   - type: The type of the desired value.
    /// - Returns: The decoded value, if any.
    @inlinable
    public func first<D: Decodable>(decodingColumn column: String, as type: D.Type) async throws -> D? {
        try await self.first()?.decode(column: column, as: D.self)
    }

    /// Using a default-configured ``SQLRowDecoder``, returns the first output row, if any, decoded as a given type.
    ///
    /// - Parameter type: The type of the desired value.
    /// - Returns: The decoded value, if any.
    @inlinable
    public func first<D: Decodable>(decoding type: D.Type) async throws -> D? {
        try await self.first(decoding: D.self, with: .init())
    }

    /// Configure a new ``SQLRowDecoder`` as specified and use it to decode and return the first output row, if any,
    /// as a given type.
    /// 
    /// - Parameters:
    ///   - type: The type of the desired value.
    ///   - prefix: See ``SQLRowDecoder/prefix``.
    ///   - keyDecodingStrategy: See ``SQLRowDecoder/keyDecodingStrategy-swift.property``.
    ///   - userInfo: See ``SQLRowDecoder/userInfo``.
    /// - Returns: The decoded value, if any.
    @inlinable
    public func first<D: Decodable>(
        decoding type: D.Type,
        prefix: String? = nil,
        keyDecodingStrategy: SQLRowDecoder.KeyDecodingStrategy = .useDefaultKeys,
        userInfo: [CodingUserInfoKey: any Sendable] = [:]
    ) async throws -> D? {
        try await self.first(decoding: D.self, with: .init(prefix: prefix, keyDecodingStrategy: keyDecodingStrategy, userInfo: userInfo))
    }

    /// Using the given ``SQLRowDecoder``, returns the first output row, if any, decoded as a given type.
    ///
    /// - Parameters:
    ///   - type: The type of the desired value.
    ///   - decoder: A configured ``SQLRowDecoder`` to use.
    /// - Returns: The decoded value, if any.
    @inlinable
    public func first<D: Decodable>(decoding type: D.Type, with decoder: SQLRowDecoder) async throws -> D? {
        try await self.first()?.decode(model: D.self, with: decoder)
    }

    /// Returns the first output row, if any.
    /// 
    /// If `self` conforms to ``SQLPartialResultBuilder``, ``SQLPartialResultBuilder/limit(_:)`` is used to avoid
    /// loading more rows than necessary from the database.
    ///
    /// - Returns: The first output row, if any.
    @inlinable
    public func first() async throws -> (any SQLRow)? {
        (self as? any SQLPartialResultBuilder)?.limit(1)
        return try await self.all().first
    }
}

// MARK: - All (EventLoopFuture)

extension SQLQueryFetcher {
    /// Returns the named column from each output row, if any, decoded as a given type.
    ///
    /// - Parameters:
    ///   - column: The name of the column to decode.
    ///   - type: The type of the desired values.
    /// - Returns: A future containing the decoded values, if any.
    @inlinable
    public func all<D: Decodable>(decodingColumn column: String, as type: D.Type) -> EventLoopFuture<[D]> {
        self.all().flatMapThrowing { try $0.map { try $0.decode(column: column, as: D.self) } }
    }

    /// Using a default-configured ``SQLRowDecoder``, returns all output rows, if any, decoded as a given type.
    ///
    /// - Parameter type: The type of the desired values.
    /// - Returns: A future containing the decoded values, if any.
    @inlinable
    public func all<D: Decodable>(decoding type: D.Type) -> EventLoopFuture<[D]> {
        self.all(decoding: D.self, with: .init())
    }
    
    /// Configure a new ``SQLRowDecoder`` as specified and use it to decode and return the output rows, if any,
    /// as a given type.
    /// 
    /// - Parameters:
    ///   - type: The type of the desired values.
    ///   - prefix: See ``SQLRowDecoder/prefix``.
    ///   - keyDecodingStrategy: See ``SQLRowDecoder/keyDecodingStrategy-swift.property``.
    ///   - userInfo: See ``SQLRowDecoder/userInfo``.
    /// - Returns: A future containing the decoded values, if any.
    @inlinable
    public func all<D: Decodable>(
        decoding type: D.Type,
        prefix: String? = nil,
        keyDecodingStrategy: SQLRowDecoder.KeyDecodingStrategy = .useDefaultKeys,
        userInfo: [CodingUserInfoKey: any Sendable] = [:]
    ) -> EventLoopFuture<[D]> {
        self.all(decoding: D.self, with: .init(prefix: prefix, keyDecodingStrategy: keyDecodingStrategy, userInfo: userInfo))
    }

    /// Using the given ``SQLRowDecoder``, returns the output rows, if any, decoded as a given type.
    ///
    /// - Parameters:
    ///   - type: The type of the desired values.
    ///   - decoder: A configured ``SQLRowDecoder`` to use.
    /// - Returns: A future containing the decoded values, if any.
    @inlinable
    public func all<D: Decodable>(decoding type: D.Type, with decoder: SQLRowDecoder) -> EventLoopFuture<[D]> {
        self.all().flatMapThrowing { try $0.map { try $0.decode(model: D.self, with: decoder) } }
    }

    /// Returns all output rows, if any.
    ///
    /// - Returns: A future containing the output rows, if any.
    @inlinable
    public func all() -> EventLoopFuture<[any SQLRow]> {
        #if swift(>=5.10)
        nonisolated(unsafe) var rows = [any SQLRow]()
        return self.run { row in rows.append(row) }.map { rows }
        #else
        let rows = RowsBox()
        return self.run { row in rows.all.append(row) }.map { rows.all }
        #endif
    }
}

// MARK: - All (async)

extension SQLQueryFetcher {
    /// Returns the named column from each output row, if any, decoded as a given type.
    ///
    /// - Parameters:
    ///   - column: The name of the column to decode.
    ///   - type: The type of the desired values.
    /// - Returns: The decoded values, if any.
    @inlinable
    public func all<D: Decodable>(decodingColumn column: String, as type: D.Type) async throws -> [D] {
        try await self.all().map { try $0.decode(column: column, as: D.self) }
    }

    /// Using a default-configured ``SQLRowDecoder``, returns all output rows, if any, decoded as a given type.
    ///
    /// - Parameter type: The type of the desired values.
    /// - Returns: The decoded values, if any.
    @inlinable
    public func all<D: Decodable>(decoding type: D.Type) async throws -> [D] {
        try await self.all(decoding: D.self, with: .init())
    }
    
    /// Configure a new ``SQLRowDecoder`` as specified and use it to decode and return the output rows, if any,
    /// as a given type.
    /// 
    /// - Parameters:
    ///   - type: The type of the desired values.
    ///   - prefix: See ``SQLRowDecoder/prefix``.
    ///   - keyDecodingStrategy: See ``SQLRowDecoder/keyDecodingStrategy-swift.property``.
    ///   - userInfo: See ``SQLRowDecoder/userInfo``.
    /// - Returns: The decoded values, if any.
    @inlinable
    public func all<D: Decodable>(
        decoding type: D.Type,
        prefix: String? = nil,
        keyDecodingStrategy: SQLRowDecoder.KeyDecodingStrategy = .useDefaultKeys,
        userInfo: [CodingUserInfoKey: any Sendable] = [:]
    ) async throws -> [D] {
        try await self.all(decoding: D.self, with: .init(prefix: prefix, keyDecodingStrategy: keyDecodingStrategy, userInfo: userInfo))
    }

    /// Using the given ``SQLRowDecoder``, returns the output rows, if any, decoded as a given type.
    ///
    /// - Parameters:
    ///   - type: The type of the desired values.
    ///   - decoder: A configured ``SQLRowDecoder`` to use.
    /// - Returns: The decoded values, if any.
    @inlinable
    public func all<D: Decodable>(decoding type: D.Type, with decoder: SQLRowDecoder) async throws -> [D] {
        try await self.all().map { try $0.decode(model: D.self, with: decoder) }
    }

    /// Returns all output rows, if any.
    ///
    /// - Returns: The output rows, if any.
    @inlinable
    public func all() async throws -> [any SQLRow] {
        #if swift(>=5.10)
        nonisolated(unsafe) var rows = [any SQLRow]()
        try await self.run { rows.append($0) }
        return rows
        #else
        let rows = RowsBox()
        try await self.run { rows.all.append($0) }
        return rows.all
        #endif
    }
}

// MARK: - Run (EventLoopFuture)

extension SQLQueryFetcher {
    /// Using a default-configured ``SQLRowDecoder``, call the provided handler closure with the result of decoding
    /// each output row, if any, as a given type.
    ///
    /// - Parameters:
    ///   - type: The type of the desired values.
    ///   - handler: A closure which receives the result of each decoding operation, row by row.
    /// - Returns: A completion future.
    @preconcurrency
    @inlinable
    public func run<D: Decodable>(decoding type: D.Type, _ handler: @escaping @Sendable (Result<D, any Error>) -> ()) -> EventLoopFuture<Void> {
        self.run(decoding: D.self, with: .init(), handler)
    }
    
    /// Configure a new ``SQLRowDecoder`` as specified, use it to to decode each output row, if any, as a given type,
    /// and call the provided handler closure with each decoding result.
    ///
    /// - Parameters:
    ///   - type: The type of the desired values.
    ///   - prefix: See ``SQLRowDecoder/prefix``.
    ///   - keyDecodingStrategy: See ``SQLRowDecoder/keyDecodingStrategy-swift.property``.
    ///   - userInfo: See ``SQLRowDecoder/userInfo``.
    ///   - handler: A closure which receives the result of each decoding operation, row by row.
    /// - Returns: A completion future.
    @preconcurrency
    @inlinable
    public func run<D: Decodable>(
        decoding type: D.Type,
        prefix: String? = nil,
        keyDecodingStrategy: SQLRowDecoder.KeyDecodingStrategy = .useDefaultKeys,
        userInfo: [CodingUserInfoKey: any Sendable] = [:],
        _ handler: @escaping @Sendable (Result<D, any Error>) -> ()
    ) -> EventLoopFuture<Void> {
        self.run(decoding: D.self, with: .init(prefix: prefix, keyDecodingStrategy: keyDecodingStrategy, userInfo: userInfo), handler)
    }

    /// Using the given ``SQLRowDecoder``, call the provided handler closure with the result of decoding each output
    /// row, if any, as a given type.
    ///
    /// - Parameters:
    ///   - type: The type of the desired values.
    ///   - decoder: A configured ``SQLRowDecoder`` to use.
    ///   - handler: A closure which receives the result of each decoding operation, row by row.
    /// - Returns: A completion future.
    @preconcurrency
    @inlinable
    public func run<D: Decodable>(
        decoding type: D.Type,
        with decoder: SQLRowDecoder,
        _ handler: @escaping @Sendable (Result<D, any Error>) -> ()
    ) -> EventLoopFuture<Void> {
        self.run { row in handler(.init { try row.decode(model: D.self, with: decoder) }) }
    }

    /// Run the query specified by the builder, calling the provided handler closure with each output row, if any, as
    /// it is received.
    ///
    /// - Parameter handler: A closure which receives each output row one at a time.
    /// - Returns: A completion future.
    @preconcurrency
    @inlinable
    public func run(_ handler: @escaping @Sendable (any SQLRow) -> ()) -> EventLoopFuture<Void> {
        self.database.execute(sql: self.query, handler)
    }
}

// MARK: - Run (async)

extension SQLQueryFetcher {
    /// Using a default-configured ``SQLRowDecoder``, call the provided handler closure with the result of decoding
    /// each output row, if any, as a given type.
    ///
    /// - Parameters:
    ///   - type: The type of the desired values.
    ///   - handler: A closure which receives the result of each decoding operation, row by row.
    @inlinable
    public func run<D: Decodable>(decoding type: D.Type, _ handler: @escaping @Sendable (Result<D, any Error>) -> ()) async throws {
        try await self.run(decoding: D.self, with: .init(), handler)
    }

    /// Configure a new ``SQLRowDecoder`` as specified, use it to to decode each output row, if any, as a given type,
    /// and call the provided handler closure with each decoding result.
    ///
    /// - Parameters:
    ///   - type: The type of the desired values.
    ///   - prefix: See ``SQLRowDecoder/prefix``.
    ///   - keyDecodingStrategy: See ``SQLRowDecoder/keyDecodingStrategy-swift.property``.
    ///   - userInfo: See ``SQLRowDecoder/userInfo``.
    ///   - handler: A closure which receives the result of each decoding operation, row by row.
    @inlinable
    @preconcurrency
    public func run<D: Decodable>(
        decoding type: D.Type,
        prefix: String? = nil,
        keyDecodingStrategy: SQLRowDecoder.KeyDecodingStrategy = .useDefaultKeys,
        userInfo: [CodingUserInfoKey: any Sendable] = [:],
        _ handler: @escaping @Sendable (Result<D, any Error>) -> ()
    ) async throws {
        try await self.run(decoding: D.self, with: .init(prefix: prefix, keyDecodingStrategy: keyDecodingStrategy, userInfo: userInfo), handler)
    }

    /// Using the given ``SQLRowDecoder``, call the provided handler closure with the result of decoding each output
    /// row, if any, as a given type.
    ///
    /// - Parameters:
    ///   - type: The type of the desired values.
    ///   - decoder: A configured ``SQLRowDecoder`` to use.
    ///   - handler: A closure which receives the result of each decoding operation, row by row.
    @inlinable
    @preconcurrency
    public func run<D: Decodable>(
        decoding type: D.Type,
        with decoder: SQLRowDecoder,
        _ handler: @escaping @Sendable (Result<D, any Error>) -> ()
    ) async throws {
        try await self.run { row in handler(Result { try row.decode(model: D.self, with: decoder) }) }
    }

    /// Run the query specified by the builder, calling the provided handler closure with each output row, if any, as
    /// it is received.
    ///
    /// - Parameter handler: A closure which receives each output row one at a time.
    @inlinable
    public func run(_ handler: @escaping @Sendable (any SQLRow) -> ()) async throws {
        try await self.database.execute(sql: self.query, handler)
    }
}

// MARK: - Utility

#if swift(<5.10)

/// A simple helper type for working with a mutable value capture across concurrency domains.
///
/// Only used before Swift 5.10.
@usableFromInline
final class RowsBox: @unchecked Sendable {
    @usableFromInline
    var all: [any SQLRow] = []
    
    @usableFromInline
    init() {}
}

#endif
