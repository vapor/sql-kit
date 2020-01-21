// MARK: Connection

extension SQLDatabase {
    /// Creates a new `PostgresCreateTypeBuilder`.
    ///
    ///     conn.create(enum: "meal", cases: "breakfast", "lunch", "dinner")...
    ///
    /// - parameters:
    ///     - name: Name of ENUM type to create.
    ///     - cases: The cases of the ENUM type.
    /// - returns: `PostgresCreateTypeBuilder`.
    public func create(enum name: String) -> SQLCreateEnumBuilder {
        return self.create(enum: SQLIdentifier(name))
    }

    /// Creates a new `PostgresCreateTypeBuilder`.
    ///
    ///     conn.create(enum: SQLIdentifier("meal"), cases: "breakfast", "lunch", "dinner")...
    ///
    /// - parameters:
    ///     - name: Name of ENUM type to create.
    ///     - cases: The cases of the ENUM type.
    /// - returns: `PostgresCreateTypeBuilder`.
    public func create(enum name: SQLExpression) -> SQLCreateEnumBuilder {
        return .init(name: name, on: self)
    }
}

/// Builds `SQLCreateEnum` queries.
///
///    conn.create(enum: "meal", cases: "breakfast", "lunch", "dinner")
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

    /// Creates a new `PostgresCreateTypeBuilder`.
    init(name: SQLExpression, on database: SQLDatabase) {
        self.createEnum = .init(name: name, values: [])
        self.database = database
    }

    public func value(_ value: String) -> Self {
        self.value(SQLLiteral.string(value))
    }

    public func value(_ value: SQLExpression) -> Self {
        self.createEnum.values.append(value)
        return self
    }
}
