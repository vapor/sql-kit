public protocol SQLRow {
    var allColumns: [String] { get }
    func contains(column: String) -> Bool
    func decodeNil(column: String) throws -> Bool
    func decode<D>(column: String, as type: D.Type) throws -> D
        where D: Decodable
}

extension SQLRow {
    public func decode<D>(model type: D.Type, prefix: String? = nil, keyDecodingStrategy: SQLRowDecoder.KeyDecodingStrategy = .useDefaultKeys) throws -> D
        where D: Decodable
    {
        var rowDecoder = SQLRowDecoder()
        rowDecoder.prefix = prefix
        rowDecoder.keyDecodingStrategy = keyDecodingStrategy
        return try rowDecoder.decode(D.self, from: self)
    }

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
