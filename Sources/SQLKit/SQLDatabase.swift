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
/// Example of manually constructing and executing a query from expressions without a query builder:
///
/// ```swift
/// var select = SQLSelect()
/// select.columns = [SQLColumn(SQLIdentifier("x"))]
/// select.tables = [SQLIdentifier("y")]
/// select.predicate = SQLBinaryExpression(
///     left: SQLColumn(SQLIdentifier("z")),
///     op: SQLBinaryOperator.equal,
///     right: SQLLiteral.numeric("1")
/// )
/// var resultRows: [SQLRow] = []
/// let sqlDb = // obtain an SQLDatabase from somewhere
///
/// try await sqlDb.execute(sql: select, resultRows.append(_:))
/// // Executed query: SELECT x FROM y WHERE z = 1, as represented in the database's SQL dialect.
/// ```
///
/// It should almost never be necessary for a client to call ``SQLDatabase/execute(sql:_:)-90wi9``
/// directly; such a need usually indicates a design flaw or functionality gap in SQLKit itself.
public protocol SQLDatabase {
    /// The ``Logger`` to be used for logging all SQLKit operations relating to a given database.
    var logger: Logger { get }
    
    /// The ``NIOCore/EventLoop`` used for asynchronous operations on a given database. If there is no
    /// specific ``NIOCore/EventLoop`` which handles the database (such as because it is a connection
    /// pool which assigns loops to connections at point of use, or because the underlying implementation
    /// is based on Swift Concurrency or some other asynchronous execution technology), it is recommended
    /// to return an event loop from ``NIOCore/EventLoopGroup/any()``.
    var eventLoop: EventLoop { get }
    
    /// The version number the connection reports for itself, provided as a type conforming to the
    /// ``SQLDatabaseReportedVersion`` protocol. If the version number is not applicable (such as for
    /// a connection pool dispatch wrapper) or not yet known, `nil` may be returned. Version numbers
    /// may also change at runtime (for example, if a connection is auto-reconnected after a remote
    /// update), or even become unknown again after being known.
    ///
    /// - Warning: This version number has nothing to do with ``SQLKit`` or (usually) of the driver
    ///   implementation for the database, nor does it represent any data stored within the database;
    ///   it is the version of the database implementation _itself_ (such as of a MySQL server or
    ///   `libsqlite3` library). A significant part of the motivation to finally add this property comes
    ///   from a larger desire to enable customizing a given ``SQLDialect``'s configuration based on the
    ///   actual feature set available at runtime instead of having to hardcode a "safe" baseline.
    var version: SQLDatabaseReportedVersion? { get }

    /// The descriptor for the SQL dialect supported by the given database. It is permitted for different
    /// connections to the same database to have different dialects, though it's unclear how this would
    /// be useful in practice.
    var dialect: SQLDialect { get }

    /// Requests that the given generic SQL query be serialized and executed on the database, and that
    /// the ``onRow`` closure be invoked once for each result row the query returns (if any).
    ///
    /// - Note: See also ``SQLDatabase/execute(sql:_:)-2gf3v``.
    func execute(
        sql query: SQLExpression,
        _ onRow: @escaping (SQLRow) -> ()
    ) -> EventLoopFuture<Void>
}

extension SQLDatabase {
    /// The ``version-22wnn`` property was added to ``SQLDatabase`` multiple years after the protocol's
    /// original definition; it was in fact the first change of any kind to the protocol since Fluent 4's
    /// original release. As such, we must provide a default value so that drivers which haven't been
    /// updated don't lose source compatibility. Conveniently, a value of `nil` represents "database
    /// version is unknown", an obvious choice for this scenario.
    public var version: SQLDatabaseReportedVersion? { nil }
}

extension SQLDatabase {
    /// Convenience utility for serializing arbitrary ``SQLExpression``s.
    ///
    /// The expression need not represent a complete query. Serialization transforms the expression into:
    ///
    /// 1. A corresponding string of raw SQL in the database's dialect, and,
    /// 2. An array of inputs to use as the values of any bound parameters of the query.
    public func serialize(_ expression: SQLExpression) -> (sql: String, binds: [Encodable]) {
        var serializer = SQLSerializer(database: self)
        expression.serialize(to: &serializer)
        return (serializer.sql, serializer.binds)
    }
 }

extension SQLDatabase {
    /// Returns a ``SQLDatabase`` which is exactly the same database as the original, except that
    /// all logging done to the new ``SQLDatabase`` will go to the specified ``Logger`` instead.
    public func logging(to logger: Logger) -> SQLDatabase {
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
    var version: SQLDatabaseReportedVersion? { self.database.version }
    var dialect: SQLDialect { self.database.dialect }
    func execute(sql query: SQLExpression, _ onRow: @escaping (SQLRow) -> ()) -> EventLoopFuture<Void> { self.database.execute(sql: query, onRow) }
}
