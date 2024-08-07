/// Builds ``SQLAlterEnum`` queries.
public final class SQLAlterEnumBuilder: SQLQueryBuilder {
    /// ``SQLAlterEnum`` query being built.
    public var alterEnum: SQLAlterEnum

    // See `SQLQueryBuilder.database`.
    public var database: any SQLDatabase
    
    // See `SQLQueryBuilder.query`.
    @inlinable
    public var query: any SQLExpression {
        self.alterEnum
    }
    
    /// Create a new ``SQLAlterEnumBuilder``.
    @usableFromInline
    init(database: any SQLDatabase, name: any SQLExpression) {
        self.database = database
        self.alterEnum = .init(name: name, value: nil)
    }
    
    /// Append a new case to the enum type.
    @inlinable
    @discardableResult
    public func add(value: String) -> Self {
        self.add(value: SQLLiteral.string(value))
    }
    
    /// Append a new case to the enum type.
    @inlinable
    @discardableResult
    public func add(value: any SQLExpression) -> Self {
        self.alterEnum.value = value
        return self
    }
}

extension SQLDatabase {
    /// Create a new ``SQLAlterEnumBuilder``.
    @inlinable
    public func alter(enum name: String) -> SQLAlterEnumBuilder {
        self.alter(enum: SQLIdentifier(name))
    }

    /// Create a new ``SQLAlterEnumBuilder``.
    @inlinable
    public func alter(enum name: any SQLExpression) -> SQLAlterEnumBuilder {
        .init(database: self, name: name)
    }
}
