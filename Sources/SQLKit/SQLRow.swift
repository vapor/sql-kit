public protocol SQLRow {
    var columns: [String] { get }
    func contains(column: String) -> Bool
    func decodeNil(column: String) throws -> Bool
    func decode<D>(column: String, as type: D.Type) throws -> D
        where D: Decodable
}

extension SQLRow {
    public func decode<D>(_ type: D.Type, prefix: String? = nil) throws -> D
        where D: Decodable
    {
        try SQLRowDecoder().decode(D.self, from: self, prefix: prefix)
    }
}
