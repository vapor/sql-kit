import NIO

public protocol SQLDatabase {
    func execute(
        _ query: SQLExpression,
        _ onRow: @escaping (SQLRow) throws -> ()
    ) -> EventLoopFuture<Void>
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
