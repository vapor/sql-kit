extension SQLDatabase {
    public func create(trigger: String, table: String, when: SQLTriggerWhen, event: SQLTriggerEvent) -> SQLCreateTriggerBuilder {
        self.create(trigger: SQLIdentifier(trigger), table: SQLIdentifier(table), when: when, event: event)
    }

    public func create(trigger: SQLExpression, table: SQLExpression, when: SQLExpression, event: SQLExpression) -> SQLCreateTriggerBuilder {
        .init(trigger: trigger, table: table, when: when, event: event, on: self)
    }
}

public final class SQLCreateTriggerBuilder: SQLQueryBuilder {
    public var createTrigger: SQLCreateTrigger

    public var database: SQLDatabase

    public var query: SQLExpression {
        return self.createTrigger
    }

    init(trigger: SQLExpression, table: SQLExpression, when: SQLExpression, event: SQLExpression, on database: SQLDatabase) {
        createTrigger = .init(trigger: trigger, table: table, when: when, event: event)
        self.database = database
    }

    public func each(_ value: SQLTriggerEach) -> SQLCreateTriggerBuilder {
        createTrigger.each = value
        return self
    }

    public func each(_ value: SQLExpression) -> SQLCreateTriggerBuilder {
        createTrigger.each = value
        return self
    }

    public func isConstraint() -> SQLCreateTriggerBuilder {
        createTrigger.isConstraint = true
        return self
    }

    public func columns(_ columns: [String]) -> SQLCreateTriggerBuilder {
        createTrigger.columns = columns.map { SQLRaw($0) }
        return self
    }

    public func columns(_ columns: [SQLExpression]) -> SQLCreateTriggerBuilder {
        createTrigger.columns = columns
        return self
    }

    public func timing(_ value: SQLTriggerTiming) -> SQLCreateTriggerBuilder {
        createTrigger.timing = value
        return self
    }

    public func timing(_ value: SQLExpression) -> SQLCreateTriggerBuilder {
        createTrigger.timing = value
        return self
    }

    public func condition(_ value: String) -> SQLCreateTriggerBuilder {
        createTrigger.condition = SQLRaw(value)
        return self
    }

    public func condition(_ value: SQLExpression) -> SQLCreateTriggerBuilder {
        createTrigger.condition = value
        return self
    }

    public func referencedTable(_ value: String) -> SQLCreateTriggerBuilder {
        createTrigger.referencedTable = SQLIdentifier(value)
        return self
    }

    public func referencedTable(_ value: SQLExpression) -> SQLCreateTriggerBuilder {
        createTrigger.referencedTable = value
        return self
    }

    public func body(_ statements: [String]) -> SQLCreateTriggerBuilder {
        createTrigger.body = statements.map { SQLRaw($0) }
        return self
    }

    public func body(_ statements: [SQLExpression]) -> SQLCreateTriggerBuilder {
        createTrigger.body = statements
        return self
    }

    public func procedure(_ name: String) -> SQLCreateTriggerBuilder {
        createTrigger.procedure = SQLIdentifier(name)
        return self
    }

    public func procedure(_ name: SQLExpression) -> SQLCreateTriggerBuilder {
        createTrigger.procedure = name
        return self
    }

    public func order(_ name: SQLTriggerOrder) -> SQLCreateTriggerBuilder {
        createTrigger.order = name
        return self
    }

    public func order(_ name: SQLExpression) -> SQLCreateTriggerBuilder {
        createTrigger.order = name
        return self
    }

    public func orderTriggerName(_ name: String) -> SQLCreateTriggerBuilder {
        createTrigger.orderTriggerName = SQLIdentifier(name)
        return self
    }

    public func orderTriggerName(_ name: SQLExpression) -> SQLCreateTriggerBuilder {
        createTrigger.orderTriggerName = name
        return self
    }

    public func run() -> EventLoopFuture<Void> {
        database.execute(sql: self.query) { _ in }
    }
}
