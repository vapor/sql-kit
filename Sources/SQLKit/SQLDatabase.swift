import Logging
import NIOCore

/// The core of an SQLKit driver. This common interface is the access point of both SQLKit itself and
/// SQLKit clients to all of the information and behaviors necessary to provide and leverage the
/// package's functionality.
///
/// Conformances to ``SQLDatabase`` are typically provided by an external database-specific driver
/// package, alongside a few utility wrapper types for handling deferred and pooled connection
/// logic and for substituting ``Logger``s. A driver package must also provide concrete
/// implementations of ``SQLDialect`` and ``SQLRow`` (both of which are hooked up via ``SQLDatabase``).
///
/// - Note: Most of ``SQLDatabase``'s functionality is relatively low-level. Clients of SQLKit
///   who want to query a database should use the higher-level API rooted at ``SQLQueryBuilder``.
///
/// Example of manually executing an SQLKit query:
///
/// ```swift
/// let sqlDb = // obtain an SQLDatabase from somewhere
/// let query = sqlDb.select().column("x").from("y").where("z", .equal, SQLLiteral.numeric("1")).select
/// var resultRows: [SQLRow] = []
///
/// try await sqlDb.execute(sql: query, resultRows.append(_:))
/// ```
///
/// It should almost never be necessary for a client to call ``SQLDatabase/execute(sql:_:)-90wi9``
/// directly; such a need generally indicates a design flaw or functionality gap in SQLKit itself.
public protocol SQLDatabase {
    /// The ``Logger`` to be used for logging all SQLKit operations relating to a given database.
    var logger: Logger { get }
    
    /// The ``NIOCore/EventLoop`` used for asynchronous operations on a given database. If there is no
    /// specific ``NIOCore/EventLoop`` which handles the database (such as because it is a connection
    /// pool which assigns loops to connections at point of use, or because the underlying implementation
    /// is based on Swift Concurrency or some other asynchronous execution technology), it is recommended
    /// to return an event loop from ``NIOCore/EventLoopGroup/any()``.
    var eventLoop: EventLoop { get }
    /// The descriptor for the SQL dialect supported by the given database. It is permitted for different
    /// connections to the same database to have different dialects, though it's unclear how this would
    /// be useful in practice.
    var dialect: SQLDialect { get }

    /// Requests that the given generic SQL query be serialized and executed on the database, and that
    /// the ``onRow`` closure be invoked once for each result row the query returns (if any).
    ///
    /// - Note: See also ``SQLDatabase/execute(sql:_:)-2gf3v`.`
    func execute(
        sql query: SQLExpression,
        _ onRow: @escaping (SQLRow) -> ()
    ) -> EventLoopFuture<Void>
}

extension SQLDatabase {
    /// Convenience utility for serializing arbitrary ``SQLExpression``s.
    ///
    /// The expression need not represent a complete query. Serialization transform the
    /// expression into:
    ///
    /// 1. A corresponding string of raw SQL in the database's dialect, and,
    /// 2. Where applicable, an array of values for any bound parameters of the query.
    ///    If not applicable, an empty array is returned.
    public func serialize(_ expression: SQLExpression) -> (sql: String, binds: [Encodable]) {
        var serializer = SQLSerializer(database: self)
        expression.serialize(to: &serializer)
        return (serializer.sql, serializer.binds)
    }
 }

extension SQLDatabase {
    /// Returns a ``SQLDatabase`` which is exactly the same database as the original, except that
    /// all logging done to the new ``SQLDatabase`` will go to the specified ``Logger`` instead.
    public func logging(to logger: Logger) -> any SQLDatabase {
        CustomLoggerSQLDatabase(database: self, logger: logger)
    }
}

/// An ``SQLDatabase`` which trivially wraps another ``SQLDatabase`` in order to substitute the
/// original's ``Logger`` with another.
///
/// - Note: Since ``SQLDatabase/logging(to:)`` returns a generic ``SQLDatabase``, this type's
///   actual implementation need not be part of the public API.
private struct CustomLoggerSQLDatabase: SQLDatabase {
    let database: SQLDatabase
    let logger: Logger
    var eventLoop: EventLoop { self.database.eventLoop }
    var dialect: SQLDialect { self.database.dialect }
    func execute(sql query: SQLExpression, _ onRow: @escaping (SQLRow) -> ()) -> EventLoopFuture<Void> { self.database.execute(sql: query, onRow) }
}
