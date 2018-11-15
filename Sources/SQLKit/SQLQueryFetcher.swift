import NIO

/// A `SQLQueryBuilder` that supports decoding results.
///
///     builder.all(decoding: Planet.self)
///
public protocol SQLQueryFetcher: SQLQueryBuilder { }

extension SQLQueryFetcher {
    // MARK: First
//    /// Decodes three types from the result set. Collects the first decoded output and returns it.
//    ///
//    ///     builder.first(decoding: Planet.self, Galaxy.self, SolarSystem.self)
//    ///
//    public func first<A, B, C>(decoding a: A.Type, _ b: B.Type, _ c: C.Type) -> EventLoopFuture<(A, B, C)?>
//        where A: SQLTable, B: SQLTable, C: SQLTable
//    {
//        return self.first().thenThrowing { row in
//            guard let row = row else {
//                return nil
//            }
//            let a = try row.decode(A.self, table: A.sqlTableIdentifierString)
//            let b = try row.decode(B.self, table: B.sqlTableIdentifierString)
//            let c = try row.decode(C.self, table: C.sqlTableIdentifierString)
//            return (a, b, c)
//        }
//    }
//
//    /// Decodes two types from the result set. Collects the first decoded output and returns it.
//    ///
//    ///     builder.first(decoding: Planet.self, Galaxy.self)
//    ///
//    public func first<A, B>(decoding a: A.Type, _ b: B.Type) -> EventLoopFuture<(A, B)?>
//        where A: SQLTable, B: SQLTable
//    {
//        return self.first().thenThrowing { row in
//            guard let row = row else {
//                return nil
//            }
//            let a = try row.decode(A.self, table: A.sqlTableIdentifierString)
//            let b = try row.decode(B.self, table: B.sqlTableIdentifierString)
//            return (a, b)
//        }
//    }
//
//    /// Collects the first decoded output and returns it.
//    ///
//    ///     builder.first(decoding: Planet.self)
//    ///
//    public func first<A>(decoding type: A.Type) -> EventLoopFuture<A?>
//        where A: SQLTable
//    {
//        return self.first().thenThrowing { row in
//            guard let row = row else {
//                return nil
//            }
//            return try row.decode(A.self, table: A.sqlTableIdentifierString)
//        }
//    }
    
    /// Collects the first raw output and returns it.
    ///
    ///     builder.first()
    ///
    public func first() -> EventLoopFuture<Database.Row?> {
        return self.all().map { $0.first }
    }
    
    // MARK: All
    
//    /// Decodes three types from the result set. Collects all decoded output into an array and returns it.
//    ///
//    ///     builder.all(decoding: Planet.self, Galaxy.self, SolarSystem.self)
//    ///
//    public func all<A, B, C>(decoding a: A.Type, _ b: B.Type, _ c: C.Type) -> EventLoopFuture<[(A, B, C)]>
//        where A: Decodable, B: Decodable, C: Decodable
//    {
//        var all: [(A, B, C)] = []
//        return run(decoding: A.self, B.self, C.self) { all.append(($0, $1, $2)) }.map { all }
//    }
//
//    /// Decodes two types from the result set. Collects all decoded output into an array and returns it.
//    ///
//    ///     builder.all(decoding: Planet.self, Galaxy.self)
//    ///
//    public func all<A, B>(decoding a: A.Type, _ b: B.Type) -> EventLoopFuture<[(A, B)]>
//        where A: Decodable, B: Decodable
//    {
//        var all: [(A, B)] = []
//        return run(decoding: A.self, B.self) { all.append(($0, $1)) }.map { all }
//    }
//
//    /// Collects all decoded output into an array and returns it.
//    ///
//    ///     builder.all(decoding: Planet.self)
//    ///
//    public func all<A>(decoding type: A.Type) -> EventLoopFuture<[A]>
//        where A: Decodable
//    {
//        var all: [A] = []
//        return run(decoding: A.self) { all.append($0) }.map { all }
//    }
    
    /// Collects all raw output into an array and returns it.
    ///
    ///     builder.all()
    ///
    public func all() -> EventLoopFuture<[Database.Row]> {
        var all: [Database.Row] = []
        return self.run { row in
            all.append(row)
        }.map { all }
    }
    
    // MARK: Run
    
    
    /// Runs the query, passing output to the supplied closure as it is recieved.
    ///
    ///     builder.run { print($0) }
    ///
    /// The returned future will signal completion of the query.
    public func run(_ handler: @escaping (Database.Row) throws -> ()) -> EventLoopFuture<Void> {
        return self.database.execute(self.query) { row in
            try handler(row)
        }
    }
    
//    /// Runs the query, passing decoded output to the supplied closure as it is recieved.
//    ///
//    ///     builder.run(decoding: Planet.self) { planet in
//    ///         // ..
//    ///     }
//    ///
//    /// The returned future will signal completion of the query.
//    public func run<A>(
//        decoding type: A.Type,
//        into handler: @escaping (A) throws -> ()
//    ) -> Future<Void>
//        where A: Decodable
//    {
//        return connectable.withSQLConnection { conn in
//            return conn.query(self.query) { row in
//                let d = try conn.decode(A.self, from: row, table: .table(any: A.self))
//                try handler(d)
//            }
//        }
//    }
//
//
//    /// Runs the query, passing decoded output to the supplied closure as it is recieved.
//    ///
//    ///     builder.run(decoding: Planet.self, Galaxy.self) { planet, galaxy in
//    ///         // ..
//    ///     }
//    ///
//    /// The returned future will signal completion of the query.
//    public func run<A, B>(
//        decoding a: A.Type, _ b: B.Type,
//        into handler: @escaping (A, B) throws -> ()
//    ) -> Future<Void>
//        where A: Decodable, B: Decodable
//    {
//        return connectable.withSQLConnection { conn in
//            return conn.query(self.query) { row in
//                let a = try conn.decode(A.self, from: row, table: .table(any: A.self))
//                let b = try conn.decode(B.self, from: row, table: .table(any: B.self))
//                try handler(a, b)
//            }
//        }
//    }
//
//    /// Runs the query, passing decoded output to the supplied closure as it is recieved.
//    ///
//    ///     builder.run(decoding: Planet.self, Galaxy.self, SolarSystem.self) { planet, galaxy, solarSystem in
//    ///         // ..
//    ///     }
//    ///
//    /// The returned future will signal completion of the query.
//    public func run<A, B, C>(
//        decoding a: A.Type, _ b: B.Type, _ c: C.Type,
//        into handler: @escaping (A, B, C) throws -> ()
//    ) -> Future<Void>
//        where A: Decodable, B: Decodable, C: Decodable
//    {
//        return connectable.withSQLConnection { conn in
//            return conn.query(self.query) { row in
//                let a = try conn.decode(A.self, from: row, table: .table(any: A.self))
//                let b = try conn.decode(B.self, from: row, table: .table(any: B.self))
//                let c = try conn.decode(C.self, from: row, table: .table(any: C.self))
//                try handler(a, b, c)
//            }
//        }
//    }
}
