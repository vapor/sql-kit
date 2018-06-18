public protocol SQLRowDecoder {
    associatedtype Row
    associatedtype TableIdentifier: SQLTableIdentifier
    
    init()
    func decode<D>(_ type: D.Type, from row: Row, table: TableIdentifier?) throws -> D
    where D: Decodable
}
