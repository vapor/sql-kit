// MARK: Connection

extension SQLDatabase {
    /// Creates a new `SQLCreateEnumBuilder`.
    ///
    ///     db.create(enum: "meal", cases: "breakfast", "lunch", "dinner")...
    ///
    /// - parameters:
    ///     - name: Name of ENUM type to create.
    ///     - cases: The cases of the ENUM type.
    /// - returns: `SQLCreateEnumBuilder`.
    public func create(enum name: String) -> SQLCreateEnumBuilder {
        return self.create(enum: SQLIdentifier(name))
    }

    /// Creates a new `SQLCreateEnumBuilder`.
    ///
    ///     db.create(enum: SQLIdentifier("meal"), cases: "breakfast", "lunch", "dinner")...
    ///
    /// - parameters:
    ///     - name: Name of ENUM type to create.
    ///     - cases: The cases of the ENUM type.
    /// - returns: `SQLCreateEnumBuilder`.
    public func create(enum name: SQLExpression) -> SQLCreateEnumBuilder {
        return .init(name: name, on: self)
    }
}

/// Builds `SQLCreateEnum` queries.
///
///    db.create(enum: "meal", cases: "breakfast", "lunch", "dinner")
///        .run()
///
/// See `SQLColumnBuilder` and `SQLQueryBuilder` for more information.
public final class SQLCreateEnumBuilder: SQLQueryBuilder {
    /// `CreateType` query being built.
    public var createEnum: SQLCreateEnum

    /// See `SQLQueryBuilder`.
    public var database: SQLDatabase

    /// See `SQLQueryBuilder`.
    public var query: SQLExpression {
        return self.createEnum
    }

    /// Creates a new `SQLCreateEnumBuilder`.
    init(name: SQLExpression, on database: SQLDatabase) {
        self.createEnum = .init(name: name, values: [])
        self.database = database
    }
    
    @discardableResult
    public func value(_ value: String) -> Self {
        self.value(SQLLiteral.string(value))
    }
    
    @discardableResult
    public func value(_ value: SQLExpression) -> Self {
        self.createEnum.values.append(value)
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
