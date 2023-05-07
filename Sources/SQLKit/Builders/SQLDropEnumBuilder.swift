import NIOCore

/// Builds ``SQLDropEnum`` queries.
public final class SQLDropEnumBuilder: SQLQueryBuilder {
    /// ``SQLDropEnum`` query being built.
    public var dropEnum: SQLDropEnum

    /// See ``SQLQueryBuilder/database``.
    public var database: any SQLDatabase

    /// See ``SQLQueryBuilder/query``.
    @inlinable
    public var query: any SQLExpression {
        self.dropEnum
    }

    /// Create a new ``SQLDropEnumBuilder``.
    @usableFromInline
    init(name: any SQLExpression, on database: any SQLDatabase) {
        self.dropEnum = .init(name: name)
        self.database = database
    }

    /// The optional `IF EXISTS` clause suppresses the error that would normally
    /// result if the type does not exist.
    @inlinable
    @discardableResult
    public func ifExists() -> Self {
        self.dropEnum.ifExists = true
        return self
    }

    /// The optional `CASCADE` clause drops other objects that depend on this type
    /// (such as table columns, functions, and operators), and in turn all objects
    /// that depend on those objects.
    @inlinable
    @discardableResult
    public func cascade() -> Self {
        self.dropEnum.cascade = true
        return self
    }
    
    /// See ``SQLQueryBuilder/run()-2sxsg``.
    @inlinable
    public func run() -> EventLoopFuture<Void> {
        guard self.database.dialect.enumSyntax == .typeName else {
            self.database.logger.warning("Database does not support standalone enum types.")
            return self.database.eventLoop.makeSucceededFuture(())
        }
        return self.database.execute(sql: self.query) { _ in }
    }
}

extension SQLDatabase {
    /// Create a new ``SQLDropEnumBuilder``.
    @inlinable
    public func drop(enum name: String) -> SQLDropEnumBuilder {
        self.drop(enum: SQLIdentifier(name))
    }

    /// Create a new ``SQLDropEnumBuilder``.
    @inlinable
    public func drop(enum name: any SQLExpression) -> SQLDropEnumBuilder {
        .init(name: name, on: self)
    }
}
