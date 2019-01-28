import NIO

public protocol SQLDatabase {
    func sqlQuery(
        _ query: SQLExpression,
        _ onRow: @escaping (SQLRow) throws -> ()
    ) -> EventLoopFuture<Void>
}

public protocol SQLRow {
    func decode<D>(column: String, as type: D.Type) throws -> D
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
