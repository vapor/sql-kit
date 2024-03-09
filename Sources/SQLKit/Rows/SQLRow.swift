/// Represents a single row in a result set returned from an executed SQL query.
///
/// Each of the protocol's requirements corresponds closely to a similarly-named requirement of Swift's
/// `KeyedDecodingContainerProtocol`, in order to provide a `Codable`-like interface for generic row access.
/// The additional logic which covers the gap between `Decodable` types and ``SQLRow``s is provided by
/// ``SQLRowDecoder``; see that type for additional discussion and further detail.
public protocol SQLRow: Sendable {
    /// The list of all column names available in the row, in no particular order.
    ///
    /// Corresponds to `KeyedDecodingContainer.allKeys`.
    var allColumns: [String] { get }
    
    /// Returns `true` if the given column name is available in the row, `false `otherwise.
    ///
    /// Corresponds to `KeyedDecodingContainer.contains(key:)`.
    func contains(column: String) -> Bool
    
    /// Must return `true` if the given column name is missing from the row **or** if it exists but has a
    /// value equivalent to an SQL `NULL`, or `false` if the column name exists with a non-`NULL` value.
    ///
    /// Corresponds to `KeyedDecodingContainer.decodeNil(forKey:)`, especially with respect to the treatment
    /// of "missing" keys.
    func decodeNil(column: String) throws -> Bool
    
    /// If the given column name exists in the row, attempt to decode it as the given type and return the
    /// result if successful.
    ///
    /// The implementation _must_ throw an error - preferably `DecodingError.keyNotFound` - if the column name
    /// does not exist in the row.
    ///
    /// Corresponds to `KeyedDecodingContainer.decode(_:forKey:)`.
    func decode<D: Decodable>(column: String, as: D.Type) throws -> D
}

extension SQLRow {
    /// Decode an entire `Decodable` "model" type at once, optionally applying a prefix and/or
    /// ``SQLRowDecoder/KeyDecodingStrategy-swift.enum`` to the type's coding keys.
    ///
    /// See ``SQLRowDecoder`` for additional details.
    ///
    /// Most users should consider using ``SQLQueryFetcher/all(decoding:prefix:keyDecodingStrategy:)-53emu``
    /// and/or ``SQLQueryFetcher/first(decoding:prefix:keyDecodingStrategy:)-34a1n`` instead.
    ///
    /// - Parameters:
    ///   - type: The type to decode.
    ///   - prefix: A prefix to discard from column names when looking up coding keys.
    ///   - keyDecodingStrategy: A decoding strategy to use for coding keys.
    ///   - userInfo: See ``SQLRowDecoder/userInfo``.
    /// - Returns: An instance of the decoded type.
    public func decode<D: Decodable>(
        model type: D.Type,
        prefix: String? = nil,
        keyDecodingStrategy: SQLRowDecoder.KeyDecodingStrategy = .useDefaultKeys,
        userInfo: [CodingUserInfoKey: any Sendable] = [:]
    ) throws -> D {
        try self.decode(model: D.self, with: .init(prefix: prefix, keyDecodingStrategy: keyDecodingStrategy, userInfo: userInfo))
    }
    
    /// Decode an entire `Decodable` "model" type at once using an explicit ``SQLRowDecoder``.
    /// 
    /// See ``SQLRowDecoder`` for additional details.
    /// 
    /// Most users should consider using ``SQLQueryFetcher/all(decoding:with:)-6n5ox`` and/or
    /// ``SQLQueryFetcher/first(decoding:with:)-58l9p`` instead.
    ///
    /// - Parameters:
    ///   - type: The type to decode.
    ///   - decoder: The ``SQLRowDecoder`` to use for decoding.
    /// - Returns: An instance of the decoded type.
    public func decode<D: Decodable>(model type: D.Type, with decoder: SQLRowDecoder) throws -> D {
        try decoder.decode(D.self, from: self)
    }
    
    /// This method exists to enable the compiler to perform type inference on the generic parameter `D` of
    /// ``SQLRow/decode(column:as:)``. Protocols can not provide default arguments to methods, which is required for
    /// inference to work with generic type parameters. It is not expected that user code will invoke this method
    /// directly; rather it will be selected by the compiler automatically, as in this example:
    ///
    /// ```
    /// let row = getAnSQLRowFromSomewhere()
    /// let id: Int = try row.decode(column: "id") // `D` is inferred to be `Int`
    /// let name = try row.decode(column: "name") // Error: No context to infer the type from
    /// struct Item { var property: Bool }
    /// let item = Item(property: try row.decode(column: "property")) // `D` inferred as `Bool`
    /// let meti = Item(property: try row.decode(column: "property", as: Bool?.self)) // Error: Can't assign Bool? to Bool
    /// ```
    public func decode<D: Decodable>(column: String, inferringAs: D.Type = D.self) throws -> D {
        try self.decode(column: column, as: D.self)
    }
}
