/// Types conforming to this protocol can be used to build SQL queries. 
public protocol SQLConnection: DatabaseQueryable, SQLConnectable where Self.Query: SQLQuery {
    /// Decodes a `Decodable` type from this connection's output.
    /// If a table is specified, values should come only from columns in that table.
    func decode<D>(_ type: D.Type, from row: Output, table: Query.Select.TableIdentifier?) throws -> D
        where D: Decodable
}

/// Capable of creating connections to a SQL database.
public protocol SQLConnectable {
    /// Associated database connection type.
    associatedtype Connection: SQLConnection
    
    /// Calls the supplied closure asynchronously with a database connection.
    func withSQLConnection<T>(_ closure: @escaping (Connection) -> (Future<T>)) -> Future<T>
}

extension SQLConnection where Self: DatabaseConnection {
    /// See `SQLConnectable`.
    public func withSQLConnection<T>(_ closure: @escaping (Database.Connection) -> (Future<T>)) -> Future<T> {
        return closure(self)
    }
}

extension DatabaseConnectionPool: SQLConnectable where
    Database.Connection: SQLConnection
{
    /// See `SQLConnectable`.
    public typealias Connection = Database.Connection
    
    /// See `SQLConnectable`.
    public func withSQLConnection<T>(_ closure: @escaping (Database.Connection) -> (Future<T>)) -> Future<T> {
        return withConnection { closure($0) }
    }
}
