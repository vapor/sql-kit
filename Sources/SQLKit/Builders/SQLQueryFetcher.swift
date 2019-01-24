import NIO

/// A `SQLQueryBuilder` that supports decoding results.
///
///     builder.all(decoding: Planet.self)
///
public protocol SQLQueryFetcher: SQLQueryBuilder { }

extension SQLQueryFetcher {
    // MARK: First
    
    /// Collects the first raw output and returns it.
    ///
    ///     builder.first()
    ///
    public func first() -> EventLoopFuture<SQLRow?> {
        return self.all().map { $0.first }
    }
    
    // MARK: All
    
    /// Collects all raw output into an array and returns it.
    ///
    ///     builder.all()
    ///
    public func all() -> EventLoopFuture<[SQLRow]> {
        var all: [SQLRow] = []
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
    public func run(_ handler: @escaping (SQLRow) throws -> ()) -> EventLoopFuture<Void> {
        return self.database.execute(self.query) { row in
            try handler(row)
        }
    }
}
