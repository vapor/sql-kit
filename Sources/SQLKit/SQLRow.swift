/// Represents a single row in a result set returned from an executed SQL query.
public protocol SQLRow {
    /// The list of all column names available in the row. Not guaranteed to be in any particular order.
    var allColumns: [String] { get }
    
    /// Returns `true` if the given column name is available in the row, `false `otherwise.
    func contains(column: String) -> Bool
    
    /// Must return `true` if the given column name is missing from the row **or** if it exists but has a
    /// value equivalent to an SQL `NULL`, or `false` if the column name exists with a non-`NULL` value.
    ///
    /// - Note: This deliberately matches the semantics of ``Swift/KeyedDecodingContainer/decodeNil(forKey:)``
    ///   as regards the treatment of "missing" keys.
    func decodeNil(column: String) throws -> Bool
    
    /// If the given column name exists in the row, attempt to decode it as the given type and return the
    /// result if successful. Must throw an error if the column name does not exist in the row.
    func decode<D>(column: String, as type: D.Type) throws -> D
        where D: Decodable
}

extension SQLRow {
    /// Decode an entire `Decodable` type at once, optionally applying a prefix and/or a decoding strategy
    /// to each key of the type before looking it up in the row.
    public func decode<D>(model type: D.Type, prefix: String? = nil, keyDecodingStrategy: SQLRowDecoder.KeyDecodingStrategy = .useDefaultKeys) throws -> D
        where D: Decodable
    {
        var rowDecoder = SQLRowDecoder()
        rowDecoder.prefix = prefix
        rowDecoder.keyDecodingStrategy = keyDecodingStrategy
        return try rowDecoder.decode(D.self, from: self)
    }
    
    /// Decode an entire `Decodable` type at once using an explicit `SQLRowDecoder`.
    public func decode<D>(model type: D.Type, with rowDecoder: SQLRowDecoder) throws -> D
        where D: Decodable
    {
        return try rowDecoder.decode(D.self, from: self)
    }
    
    /// This method exists to enable the compiler to perform type inference on
    /// the generic parameter `D` of `SQLRow.decode(column:as:)`. Protocols can
    /// not provide default arguments to methods, which is required for
    /// inference to work with generic type parameters. It is not expected that
    /// user code will invoke this method directly; rather it will be selected
    /// by the compiler automatically, as in this example:
    ///
    /// ```
    /// let row = getAnSQLRowFromSomewhere()
    /// let id: Int = try row.decode(column: "id") // `D` is inferred to be `Int`
    /// let name = try row.decode(column: "name") // Error: No context to infer the type from
    /// struct Item { var property: Bool }
    /// let item = Item(property: try row.decode(column: "property")) // `D` inferred as `Bool`
    /// let meti = Item(property: try row.decode(column: "property", as: Bool?.self)) // Error: Can't assign Bool? to Bool
    /// ```
    ///
    /// - Note: The presence of this method in a protocol extension allows it to
    ///         be available without requiring explicit support from individual
    ///         database drivers.
    ///
    /// - Todo: Find a way to accomplish this result without polluting the
    ///         method namespace.
    public func decode<D>(column: String, inferringAs type: D.Type = D.self) throws -> D where D: Decodable {
        return try self.decode(column: column, as: D.self)
    }
}
