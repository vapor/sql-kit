import NIO

public protocol SQLDatabase {
    associatedtype Query: SQLQuery
    associatedtype Row: SQLRow
    func execute(_ query: Query, _ onRow: @escaping (Row) throws -> ()) -> EventLoopFuture<Void>
}

public protocol SQLRow {
    func decode<D>(_ type: D.Type, table: String?) throws -> D
        where D: Decodable
}
//
//extension SQLRow {
//    public func decode<T>(_ type: T.Type) throws -> T
//        where T: SQLTable
//    {
//        return try self.decode(T.self, table: T.sqlTableIdentifierString)
//    }
//}
