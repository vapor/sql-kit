/// Builds raw SQL queries and automatically binds values.
///
///     conn.raw2("SELECT * FROM planets WHERE name = \(param: "Earth")")
///         .all(decoding: Planet.self)
///
public final class SQLAutobindingQueryBuilder: SQLQueryBuilder, SQLQueryFetcher {
    
    /// Raw query being built.
    var sql: SQLQueryString
    
    /// See `SQLQueryBuilder`.
    public var database: SQLDatabase
    
    /// See `SQLQueryBuilder`.
    public var query: SQLExpression {
        return sql
    }
    
    /// Creates a new `SQLAutobindingQueryBuilder`.
    public init(_ sql: SQLQueryString, on database: SQLDatabase) {
        self.database = database
        self.sql = sql
    }
}

// MARK: Connection

extension SQLDatabase {
    public func raw2(_ sql: SQLQueryString) -> SQLAutobindingQueryBuilder {
        return .init(sql, on: self)
    }
}

extension Array: SQLExpression where Element == SQLQueryString.Fragment {
    public func serialize(to serializer: inout SQLSerializer) {
        for fragment in self {
            switch fragment {
            case let .literal(str):
                serializer.write(str)
            case let .value(v):
                serializer.dialect.nextBindPlaceholder().serialize(to: &serializer)
                serializer.binds.append(v)
            }
        }
    }
}
