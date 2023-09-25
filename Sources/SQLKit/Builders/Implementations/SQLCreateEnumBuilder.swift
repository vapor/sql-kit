import NIOCore

/// Builds ``SQLCreateEnum`` queries.
///
///    db.create(enum: "meal")
///        .value("breakfast")
///        .value("lunch")
///        .value("dinner")
///        .run()
public final class SQLCreateEnumBuilder: SQLQueryBuilder {
    /// ``SQLCreateEnum`` query being built.
    public var createEnum: SQLCreateEnum

    /// See ``SQLQueryBuilder/database``.
    public var database: any SQLDatabase

    /// See ``SQLQueryBuilder/query``.
    @inlinable
    public var query: any SQLExpression {
        self.createEnum
    }

    /// Create a new ``SQLCreateEnumBuilder``.
    @usableFromInline
    init(name: any SQLExpression, on database: any SQLDatabase) {
        self.createEnum = .init(name: name, values: [])
        self.database = database
    }
    
    /// Add an enum case to the built type.
    @inlinable
    @discardableResult
    public func value(_ value: String) -> Self {
        self.value(SQLLiteral.string(value))
    }
    
    /// Add a enum case to the built type.
    @inlinable
    @discardableResult
    public func value(_ value: any SQLExpression) -> Self {
        self.createEnum.values.append(value)
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
    /// Create a new ``SQLCreateEnumBuilder``.
    @inlinable
    public func create(enum name: String) -> SQLCreateEnumBuilder {
        self.create(enum: SQLIdentifier(name))
    }

    /// Create a new ``SQLCreateEnumBuilder``.
    @inlinable
    public func create(enum name: any SQLExpression) -> SQLCreateEnumBuilder {
        .init(name: name, on: self)
    }
}
