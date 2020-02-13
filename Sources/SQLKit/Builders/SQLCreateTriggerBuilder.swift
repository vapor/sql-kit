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

    /// Identifies whether the trigger applies to each row or each statement.
    /// - Parameter value: The option to use.
    public func each(_ value: SQLTriggerEach) -> SQLCreateTriggerBuilder {
        createTrigger.each = value
        return self
    }

    /// Identifies whether the trigger applies to each row or each statement.
    /// - Parameter value: The appropriate row or statement value for the language.
    public func each(_ value: SQLExpression) -> SQLCreateTriggerBuilder {
        createTrigger.each = value
        return self
    }

    /// Specifies this is a constraint trigger.
    public func isConstraint() -> SQLCreateTriggerBuilder {
        createTrigger.isConstraint = true
        return self
    }

    /// The columns which the trigger applies to.
    /// - Parameter columns: The names of the columns.
    public func columns(_ columns: [String]) -> SQLCreateTriggerBuilder {
        createTrigger.columns = columns.map { SQLRaw($0) }
        return self
    }

    /// The columns which the trigger applies to.
    /// - Parameter columns: The names of the columns.
    public func columns(_ columns: [SQLExpression]) -> SQLCreateTriggerBuilder {
        createTrigger.columns = columns
        return self
    }

    /// The timing of the trigger.
    /// - Parameter value: When the trigger applies.
    /// ### Note ###
    /// Only applicable to constraint triggers.
    public func timing(_ value: SQLTriggerTiming) -> SQLCreateTriggerBuilder {
        createTrigger.timing = value
        return self
    }

    /// The timing of the trigger.
    /// - Parameter value: The appropriate option.
    /// ### Note ###
    /// Only applicable to constraint triggers.
    public func timing(_ value: SQLExpression) -> SQLCreateTriggerBuilder {
        createTrigger.timing = value
        return self
    }

    /// A Boolean expression that determines whether the trigger function will actually be executed
    /// - Parameter value: The condition
    public func condition(_ value: String) -> SQLCreateTriggerBuilder {
        createTrigger.condition = SQLRaw(value)
        return self
    }

    /// A Boolean expression that determines whether the trigger function will actually be executed
    /// - Parameter value: The condition
    public func condition(_ value: SQLExpression) -> SQLCreateTriggerBuilder {
        createTrigger.condition = value
        return self
    }

    /// The (possibly schema-qualified) name of another table referenced by the constraint
    /// - Parameter value: The name of the table.
    /// ### Note ###
    /// This option is used for foreign-key constraints and is not recommended for general use. This can only be specified for constraint triggers.
    public func referencedTable(_ value: String) -> SQLCreateTriggerBuilder {
        createTrigger.referencedTable = SQLIdentifier(value)
        return self
    }

    /// The (possibly schema-qualified) name of another table referenced by the constraint
    /// - Parameter value: The name of the table.
    /// ### Note ###
    /// This option is used for foreign-key constraints and is not recommended for general use. This can only be specified for constraint triggers.
    public func referencedTable(_ value: SQLExpression) -> SQLCreateTriggerBuilder {
        createTrigger.referencedTable = value
        return self
    }

    /// The body of the trigger for those dialects that include the body in the trigger itself.
    /// - Parameter statements: The statements for the body of the trigger.
    public func body(_ statements: [String]) -> SQLCreateTriggerBuilder {
        createTrigger.body = statements.map { SQLRaw($0) }
        return self
    }

    /// The body of the trigger for those dialects that include the body in the trigger itself.
    /// - Parameter statements: The statements for the body of the trigger.
    public func body(_ statements: [SQLExpression]) -> SQLCreateTriggerBuilder {
        createTrigger.body = statements
        return self
    }

    /// The name of the procedure the trigger will execute for dialects that don't include the body in the trigger itself.
    /// - Parameter name: The name of the procedure.
    public func procedure(_ name: String) -> SQLCreateTriggerBuilder {
        createTrigger.procedure = SQLIdentifier(name)
        return self
    }

    /// The name of the procedure the trigger will execute for dialects that don't include the body in the trigger itself.
    /// - Parameter name: The name of the procedure.
    public func procedure(_ name: SQLExpression) -> SQLCreateTriggerBuilder {
        createTrigger.procedure = name
        return self
    }

    /// Identifies whether this trigger follows or precedes the referenced trigger.
    /// - Parameters:
    ///   - precedence: The precedence of this trigger in relation to `otherTriggerName`
    ///   - otherTriggerName: The name of the other trigger.
    public func order(precedence: SQLTriggerOrder, otherTriggerName: String) -> SQLCreateTriggerBuilder {
        createTrigger.order = precedence
        createTrigger.orderTriggerName = SQLIdentifier(otherTriggerName)
        return self
    }

    /// Identifies whether this trigger follows or precedes the referenced trigger.
    /// - Parameters:
    ///   - precedence: The precedence of this trigger in relation to `otherTriggerName`
    ///   - otherTriggerName: The name of the other trigger.
    public func order(precedence: SQLTriggerOrder, otherTriggerName: SQLExpression) -> SQLCreateTriggerBuilder {
        createTrigger.order = otherTriggerName
        createTrigger.orderTriggerName = otherTriggerName
        return self
    }

    /// Identifies whether this trigger follows or precedes the referenced trigger.
    /// - Parameters:
    ///   - precedence: The precedence of this trigger in relation to `otherTriggerName`
    ///   - otherTriggerName: The name of the other trigger.
    public func order(precedence: SQLExpression, otherTriggerName: SQLExpression) -> SQLCreateTriggerBuilder {
        createTrigger.order = precedence
        createTrigger.orderTriggerName = otherTriggerName
        return self
    }

    public func run() -> EventLoopFuture<Void> {
        database.execute(sql: self.query) { _ in }
    }
}
