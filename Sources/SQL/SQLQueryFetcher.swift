/// A `SQLQueryBuilder` that supports decoding results.
///
///     builder.all(decoding: Planet.self)
///
public protocol SQLQueryFetcher: SQLQueryBuilder { }

extension SQLQueryFetcher {
    // MARK: All
    
    /// Collects all raw output into an array and returns it.
    ///
    ///     builder.all()
    ///
    public func all() -> Future<[Connection.Output]> {
        var all: [Connection.Output] = []
        return connection.query(query) { all.append($0) }.map { all }
    }
    
    /// Collects all decoded output into an array and returns it.
    ///
    ///     builder.all(decoding: Planet.self)
    ///
    public func all<A>(decoding type: A.Type) -> Future<[A]>
        where A: Decodable
    {
        var all: [A] = []
        return run(decoding: A.self) { all.append($0) }.map { all }
    }
    
    /// Decodes two types from the result set. Collects all decoded output into an array and returns it.
    ///
    ///     builder.all(decoding: Planet.self, Galaxy.self)
    ///
    public func all<A, B>(decoding a: A.Type, _ b: B.Type) -> Future<[(A, B)]>
        where A: Decodable, B: Decodable
    {
        var all: [(A, B)] = []
        return run(decoding: A.self, B.self) { all.append(($0, $1)) }.map { all }
    }
    
    /// Decodes three types from the result set. Collects all decoded output into an array and returns it.
    ///
    ///     builder.all(decoding: Planet.self, Galaxy.self, SolarSystem.self)
    ///
    public func all<A, B, C>(decoding a: A.Type, _ b: B.Type, _ c: C.Type) -> Future<[(A, B, C)]>
        where A: Decodable, B: Decodable, C: Decodable
    {
        var all: [(A, B, C)] = []
        return run(decoding: A.self, B.self, C.self) { all.append(($0, $1, $2)) }.map { all }
    }
    
    // MARK: Run
    
    
    /// Runs the query, passing output to the supplied closure as it is recieved.
    ///
    ///     builder.run { print($0) }
    ///
    /// The returned future will signal completion of the query.
    public func run(_ handler: @escaping (Connection.Output) throws -> ()) -> Future<Void> {
        return connection.query(query, handler)
    }
    
    /// Runs the query, passing decoded output to the supplied closure as it is recieved.
    ///
    ///     builder.run(decoding: Planet.self) { planet in
    ///         // ..
    ///     }
    ///
    /// The returned future will signal completion of the query.
    public func run<A>(
        decoding type: A.Type,
        into handler: @escaping (A) throws -> ()
    ) -> Future<Void>
        where A: Decodable
    {
        return run { row in
            let d = try self.connection.decode(A.self, from: row, table: .table(any: A.self))
            try handler(d)
        }
    }
    
    
    /// Runs the query, passing decoded output to the supplied closure as it is recieved.
    ///
    ///     builder.run(decoding: Planet.self, Galaxy.self) { planet, galaxy in
    ///         // ..
    ///     }
    ///
    /// The returned future will signal completion of the query.
    public func run<A, B>(
        decoding a: A.Type, _ b: B.Type,
        into handler: @escaping (A, B) throws -> ()
    ) -> Future<Void>
        where A: Decodable, B: Decodable
    {
        return run { row in
            let a = try self.connection.decode(A.self, from: row, table: .table(any: A.self))
            let b = try self.connection.decode(B.self, from: row, table: .table(any: B.self))
            try handler(a, b)
        }
    }
    
    /// Runs the query, passing decoded output to the supplied closure as it is recieved.
    ///
    ///     builder.run(decoding: Planet.self, Galaxy.self, SolarSystem.self) { planet, galaxy, solarSystem in
    ///         // ..
    ///     }
    ///
    /// The returned future will signal completion of the query.
    public func run<A, B, C>(
        decoding a: A.Type, _ b: B.Type, _ c: C.Type,
        into handler: @escaping (A, B, C) throws -> ()
    ) -> Future<Void>
        where A: Decodable, B: Decodable, C: Decodable
    {
        return run { row in
            let a = try self.connection.decode(A.self, from: row, table: .table(any: A.self))
            let b = try self.connection.decode(B.self, from: row, table: .table(any: B.self))
            let c = try self.connection.decode(C.self, from: row, table: .table(any: C.self))
            try handler(a, b, c)
        }
    }
}
