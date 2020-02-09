extension SQLDatabase {
    public func alter(enum name: String) -> SQLAlterEnumBuilder {
        self.alter(enum: SQLIdentifier(name))
    }

    public func alter(enum name: SQLExpression) -> SQLAlterEnumBuilder {
        .init(database: self, name: name)
    }
}

public final class SQLAlterEnumBuilder: SQLQueryBuilder {
    public var database: SQLDatabase
    public var alterEnum: SQLAlterEnum
    public var query: SQLExpression {
        self.alterEnum
    }

    init(database: SQLDatabase, name: SQLExpression) {
        self.database = database
        self.alterEnum = .init(name: name, value: nil)
    }

    public func add(value: String) -> Self {
        self.add(value: SQLLiteral.string(value))
    }

    public func add(value: SQLExpression) -> Self {
        self.alterEnum.value = value
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
