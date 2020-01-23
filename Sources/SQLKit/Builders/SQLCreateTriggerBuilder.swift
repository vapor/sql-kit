extension SQLDatabase {
    public func create(trigger: SQLExpression, table: SQLExpression, procedure: SQLExpression, when: SQLExpression, event: SQLExpression) -> SQLCreateTriggerBuilder {
        .init(trigger: trigger, table: table, procedure: procedure, when: when, event: event, on: self)
    }

    public func create(trigger: String, table: String, procedure: String, when: SQLTriggerWhen, event: SQLTriggerEvent) -> SQLCreateTriggerBuilder {
        self.create(trigger: SQLIdentifier(trigger), table: SQLIdentifier(table), procedure: SQLIdentifier(procedure), when: when, event: event)
    }
}

public final class SQLCreateTriggerBuilder: SQLQueryBuilder {
    public var createTrigger: SQLCreateTrigger

    public var database: SQLDatabase

    public var query: SQLExpression {
        return self.createTrigger
    }

    init(trigger: SQLExpression, table: SQLExpression, procedure: SQLExpression, when: SQLExpression, event: SQLExpression, on database: SQLDatabase) {
        createTrigger = .init(trigger: trigger, table: table, procedure: procedure, when: when, event: event)
        self.database = database
    }

    public func each(_ value: SQLExpression) -> SQLCreateTriggerBuilder {
        createTrigger.each = value
        return self
    }

    public func each(_ value: SQLTriggerEach) -> SQLCreateTriggerBuilder {
        createTrigger.each = value
        return self
    }

    public func isConstraint() -> SQLCreateTriggerBuilder {
        createTrigger.isConstraint = true
        return self
    }

    public func columns(_ columns: [SQLExpression]) -> SQLCreateTriggerBuilder {
        createTrigger.columns = columns
        return self
    }

    public func timing(_ value: SQLExpression) -> SQLCreateTriggerBuilder {
        createTrigger.timing = value
        return self
    }

    public func timing(_ value: SQLTriggerTiming) -> SQLCreateTriggerBuilder {
        createTrigger.timing = value
        return self
    }

    public func condition(_ value: SQLExpression) -> SQLCreateTriggerBuilder {
        createTrigger.condition = value
        return self
    }

    public func referencedTable(_ value: SQLExpression) -> SQLCreateTriggerBuilder {
        createTrigger.referencedTable = value
        return self
    }

    public func body(_ statements: [SQLExpression]) -> SQLCreateTriggerBuilder {
        createTrigger.body = statements
        return self
    }

    public func run() -> EventLoopFuture<Void> {
        database.execute(sql: self.query) { _ in }
    }
}
