extension SQLDatabase {
    /// Creates a new `SQLDropEnumBuilder`.
    ///
    ///     sql.drop(enum: "meal").run()
    ///
    /// - parameters:
    ///     - type: Name of type to drop.
    /// - returns: `SQLDropEnumBuilder`.
    public func drop(enum name: String) -> SQLDropEnumBuilder {
        self.drop(enum: SQLIdentifier(name))
    }

    /// Creates a new `SQLDropEnumBuilder`.
    ///
    ///     sql.drop(enum: "meal").run()
    ///
    /// - parameters:
    ///     - type: Name of type to drop.
    /// - returns: `SQLDropEnumBuilder`.
    public func drop(enum name: SQLExpression) -> SQLDropEnumBuilder {
        .init(name: name, on: self)
    }
}

/// Builds `SQLDropEnumBuilder` queries.
///
///     conn.drop(type: "meal").run()
///
/// See `SQLQueryBuilder` for more information.
public final class SQLDropEnumBuilder: SQLQueryBuilder {
    /// `DropType` query being built.
    public var dropEnum: SQLDropEnum

    /// See `SQLQueryBuilder`.
    public var database: SQLDatabase

    /// See `SQLQueryBuilder`.
    public var query: SQLExpression {
        return self.dropEnum
    }

    /// Creates a new `SQLDropEnumBuilder`.
    init(name: SQLExpression, on database: SQLDatabase) {
        self.dropEnum = .init(name: name)
        self.database = database
    }

    /// The optional `IF EXISTS` clause suppresses the error that would normally
    /// result if the type does not exist.
    public func ifExists() -> Self {
        self.dropEnum.ifExists = true
        return self
    }

    /// The optional `CASCADE` clause drops other objects that depend on this type
    /// (such as table columns, functions, and operators), and in turn all objects
    /// that depend on those objects.
    public func cascade() -> Self {
        self.dropEnum.cascade = true
        return self
    }
    
    public func run() -> EventLoopFuture<Void> {
        guard self.database.dialect.enumSyntax == .typeName else {
            self.database.logger.warning("Database does not support enum types.")
            return self.database.eventLoop.makeSucceededFuture(())
        }
        return self.database.execute(sql: self.query) { _ in }
    }
}
