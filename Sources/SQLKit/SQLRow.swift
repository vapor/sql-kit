public protocol SQLRow {
    func decode<D>(column: String, as type: D.Type) throws -> D
        where D: Decodable
}
