import Async


public protocol SQLQueryBuilder: class {
    associatedtype Connection: SQLConnection
    var query: Connection.Query { get }
    var connection: Connection { get }
}

extension SQLQueryBuilder {
    public func run() -> Future<Void> {
        return connection.query(query) { _ in }
    }
}

public protocol SQLQueryFetcher: SQLQueryBuilder { }

extension SQLQueryFetcher {
    // MARK: All
    
    public func all() -> Future<[Connection.Output]> {
        var all: [Connection.Output] = []
        return connection.query(query) { all.append($0) }.map { all }
    }
    
    public func run(_ handler: @escaping (Connection.Output) throws -> ()) -> Future<Void> {
        return connection.query(query, handler)
    }
}

extension SQLQueryFetcher {
    // MARK: Decode
    
    public func all<D>(decoding type: D.Type) -> Future<[D]>
        where D: Decodable
    {
        var all: [D] = []
        return run(decoding: D.self) { all.append($0) }.map { all }
    }
    
    public func all<A, B>(decoding a: A.Type, _ b: B.Type) -> Future<[(A, B)]>
        where A: SQLTable, B: SQLTable
    {
        var all: [(A, B)] = []
        return run(decoding: A.self, B.self) { all.append(($0, $1)) }.map { all }
    }
    
    public func all<A, B, C>(decoding a: A.Type, _ b: B.Type, _ c: C.Type) -> Future<[(A, B, C)]>
        where A: SQLTable, B: SQLTable, C: SQLTable
    {
        var all: [(A, B, C)] = []
        return run(decoding: A.self, B.self, C.self) { all.append(($0, $1, $2)) }.map { all }
    }

    public func run<A, B, C>(
        decoding a: A.Type, _ b: B.Type, _ c: C.Type,
        into handler: @escaping (A, B, C) throws -> ()
    ) -> Future<Void>
        where A: SQLTable, B: SQLTable, C: SQLTable
    {
        return run { row in
            let a = try self.connection.decode(A.self, from: row, table: .table(A.self))
            let b = try self.connection.decode(B.self, from: row, table: .table(B.self))
            let c = try self.connection.decode(C.self, from: row, table: .table(C.self))
            try handler(a, b, c)
        }
    }
    
    public func run<A, B>(
        decoding a: A.Type, _ b: B.Type,
        into handler: @escaping (A, B) throws -> ()
    ) -> Future<Void>
        where A: SQLTable, B: SQLTable
    {
        return run { row in
            let a = try self.connection.decode(A.self, from: row, table: .table(A.self))
            let b = try self.connection.decode(B.self, from: row, table: .table(B.self))
            try handler(a, b)
        }
    }
    
    public func run<D>(
        decoding type: D.Type,
        into handler: @escaping (D) throws -> ()
    ) -> Future<Void>
        where D: Decodable
    {
        return run { row in
            let d = try self.connection.decode(D.self, from: row, table: nil)
            try handler(d)
        }
    }
}


//extension Dictionary where Key == SQLiteColumn, Value == SQLiteData {
//    public func decode<Table>(_ type: Table.Type) throws -> Table where Table: SQLiteTable {
//        return try decode(Table.self, from: Table.sqlTableIdentifier.name.string)
//    }
//
//    public func decode<D>(_ type: D.Type, from table: SQLiteQuery.Expression.ColumnIdentifier.TableIdentifier) throws -> D where D: Decodable {
//        return try SQLiteRowDecoder().decode(D.self, from: self, table: table)
//    }
//}
