public protocol SQLRow {
    var allColumns: [String] { get }
    func contains(column: String) -> Bool
    func decodeNil(column: String) throws -> Bool
    func decode<D>(column: String, as type: D.Type) throws -> D
        where D: Decodable
}

extension SQLRow {
    public func decode<D>(model type: D.Type, keyPrefix: String? = nil, keyDecodingStrategy: SQLRowDecoder.KeyDecodingStrategy = .useDefaultKeys) throws -> D
        where D: Decodable
    {
        var rowDecoder = SQLRowDecoder()
        rowDecoder.keyPrefix = keyPrefix
        rowDecoder.keyDecodingStrategy = keyDecodingStrategy
        return try rowDecoder.decode(D.self, from: self)
    }

    public func decode<D>(model type: D.Type, with rowDecoder: SQLRowDecoder) throws -> D
        where D: Decodable
    {
        return try rowDecoder.decode(D.self, from: self)
    }
}
