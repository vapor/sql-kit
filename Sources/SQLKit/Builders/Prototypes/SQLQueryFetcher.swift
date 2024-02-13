import class NIOCore.EventLoopFuture

/// Common definitions for ``SQLQueryBuilder``s which support decoding results.
public protocol SQLQueryFetcher: SQLQueryBuilder {}

extension SQLQueryFetcher {
    // MARK: First

    /// Returns the named column from the first output row, if any, decoded as a given type.
    public func first<D: Decodable>(decodingColumn column: String, as: D.Type) -> EventLoopFuture<D?> {
        self.first().flatMapThrowing {
            try $0?.decode(column: column, as: D.self)
        }
    }

    /// Returns the first output row, if any, decoded as a given type.
    public func first<D: Decodable>(decoding: D.Type) -> EventLoopFuture<D?> {
        self.first().flatMapThrowing {
            try $0?.decode(model: D.self)
        }
    }
    
    /// Returns the first output row, if any.
    public func first() -> EventLoopFuture<(any SQLRow)?> {
        if let partialBuilder = self as? (any SQLPartialResultBuilder & SQLQueryFetcher) {
            return partialBuilder.limit(1).all().map(\.first)
        } else {
            return self.all().map(\.first)
        }
    }
    
    // MARK: All

    /// Returns the named column from all output rows, if any, decoded as a given type.
    public func all<D: Decodable>(decodingColumn column: String, as: D.Type) -> EventLoopFuture<[D]> {
        self.all().flatMapThrowing {
            try $0.map {
                try $0.decode(column: column, as: D.self)
            }
        }
    }

    /// Returns all output rows, if any, decoded as a given type.
    public func all<D: Decodable>(decoding: D.Type) -> EventLoopFuture<[D]> {
        self.all().flatMapThrowing {
            try $0.map {
                try $0.decode(model: D.self)
            }
        }
    }
    
    /// Collects all raw output into an array and returns it.
    public func all() -> EventLoopFuture<[any SQLRow]> {
        let rows = RowsBox()
        
        return self.run { row in
            rows.all.append(row)
        }.map { rows.all }
    }
    
    // MARK: Run

    /// Executes the query, decoding each output row as a given type and calling a provided handler with the result.
    @preconcurrency
    public func run<D: Decodable>(decoding: D.Type, _ handler: @escaping @Sendable (Result<D, any Error>) -> ()) -> EventLoopFuture<Void> {
        self.run { row in
            handler(Result {
                try row.decode(model: D.self)
            })
        }
    }
    
    /// Runs the query, passing output to the supplied closure as it is recieved.
    /// The returned future signals completion of the query.
    @preconcurrency
    public func run(_ handler: @escaping @Sendable (any SQLRow) -> ()) -> EventLoopFuture<Void> {
        self.database.execute(sql: self.query, handler)
    }
}

@usableFromInline
internal final class RowsBox: @unchecked Sendable {
    @usableFromInline
    var all: [any SQLRow] = []
    
    @usableFromInline
    init() {}
}
