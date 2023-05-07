/// Builds ``SQLCreateTrigger`` queries.
public final class SQLCreateTriggerBuilder: SQLQueryBuilder {
    /// ``SQLCreateTrigger`` query being built.
    public var createTrigger: SQLCreateTrigger

    /// See ``SQLQueryBuilder/database``.
    public var database: any SQLDatabase

    /// See ``SQLQueryBuilder/query``.
    @inlinable
    public var query: any SQLExpression {
        self.createTrigger
    }

    /// Create a new ``SQLCreateTriggerBuilder``.
    @usableFromInline
    init(trigger: any SQLExpression, table: any SQLExpression, when: any SQLExpression, event: any SQLExpression, on database: any SQLDatabase) {
        self.createTrigger = .init(trigger: trigger, table: table, when: when, event: event)
        self.database = database
    }

    /// Identifies whether the trigger applies to each row or each statement.
    @inlinable
    @discardableResult
    public func each(_ value: SQLTriggerEach) -> Self {
        self.createTrigger.each = value
        return self
    }

    /// Identifies whether the trigger applies to each row or each statement.
    @inlinable
    @discardableResult
    public func each(_ value: any SQLExpression) -> Self {
        self.createTrigger.each = value
        return self
    }

    /// Specifies this is a constraint trigger.
    @inlinable
    @discardableResult
    public func isConstraint() -> Self {
        self.createTrigger.isConstraint = true
        return self
    }

    /// Specify the columns to which the trigger applies.
    @inlinable
    @discardableResult
    public func columns(_ columns: [String]) -> Self {
        self.columns(columns.map(SQLIdentifier.init(_:)))
    }

    /// Specify the columns to which the trigger applies.
    @inlinable
    @discardableResult
    public func columns(_ columns: [any SQLExpression]) -> Self {
        self.createTrigger.columns = columns
        return self
    }

    /// Specify the trigger's timing.
    ///
    /// - Note: Only applies to constraint triggers.
    @inlinable
    @discardableResult
    public func timing(_ value: SQLTriggerTiming) -> Self {
        self.createTrigger.timing = value
        return self
    }

    /// Specify the trigger's timing.
    ///
    /// - Note: Only applies to constraint triggers.
    @inlinable
    @discardableResult
    public func timing(_ value: any SQLExpression) -> Self {
        self.createTrigger.timing = value
        return self
    }

    /// Specify a conditional expression which determines whether the trigger is actually executed.
    @available(*, deprecated, message: "Specifying conditions as raw strings is unsafe. Use `SQLBinaryExpression` etc. instead.")
    @inlinable
    @discardableResult
    public func condition(_ value: String) -> Self {
        self.condition(SQLRaw(value))
    }

    /// Specify a conditional expression which determines whether the trigger is actually executed.
    @inlinable
    @discardableResult
    public func condition(_ value: any SQLExpression) -> Self {
        self.createTrigger.condition = value
        return self
    }

    /// Specify the name of another table referenced by the constraint.
    ///
    /// To specify a schema-qualified table, use ``SQLQualifiedTable``.
    ///
    /// - Note: This option is used for foreign key constraints and is not recommended for general use. Only applies to constraint triggers.
    @inlinable
    @discardableResult
    public func referencedTable(_ value: String) -> Self {
        self.referencedTable(SQLIdentifier(value))
    }

    /// Specify the name of another table referenced by the constraint.
    ///
    /// To specify a schema-qualified table, use ``SQLQualifiedTable``.
    ///
    /// - Note: This option is used for foreign key constraints and is not recommended for general use. Only applies to constraint triggers.
    @inlinable
    @discardableResult
    public func referencedTable(_ value: any SQLExpression) -> Self {
        self.createTrigger.referencedTable = value
        return self
    }

    /// Specify a body for the trigger.
    @available(*, deprecated, message: "Specifying SQL statements as raw strings is unsafe. Use `SQLQueryString` or `SQLRaw` explicitly.")
    @inlinable
    @discardableResult
    public func body(_ statements: [String]) -> Self {
        self.body(statements.map { SQLRaw($0) })
    }

    /// Specify a body for the trigger.
    @inlinable
    @discardableResult
    public func body(_ statements: [any SQLExpression]) -> Self {
        self.createTrigger.body = statements
        return self
    }

    /// Specify a procedure name for the trigger to execute.
    @inlinable
    @discardableResult
    public func procedure(_ name: String) -> Self {
        self.procedure(SQLIdentifier(name))
    }

    /// Specify a procedure name for the trigger to execute.
    @inlinable
    @discardableResult
    public func procedure(_ name: any SQLExpression) -> Self {
        self.createTrigger.procedure = name
        return self
    }

    /// Specify whether this trigger precedes or follows a referenced trigger.
    @inlinable
    @discardableResult
    public func order(precedence: SQLTriggerOrder, otherTriggerName: String) -> Self {
        self.order(precedence: precedence, otherTriggerName: SQLIdentifier(otherTriggerName))
    }

    /// Specify whether this trigger precedes or follows a referenced trigger.
    @inlinable
    @discardableResult
    public func order(precedence: SQLTriggerOrder, otherTriggerName: any SQLExpression) -> Self {
        self.order(precedence: precedence as any SQLExpression, otherTriggerName: otherTriggerName)
    }

    /// Specify whether this trigger precedes or follows a referenced trigger.
    @inlinable
    @discardableResult
    public func order(precedence: any SQLExpression, otherTriggerName: any SQLExpression) -> Self {
        self.createTrigger.order = precedence
        self.createTrigger.orderTriggerName = otherTriggerName
        return self
    }
}

extension SQLDatabase {
    /// Create a new ``SQLCreateTriggerBuilder``.
    @inlinable
    public func create(trigger: String, table: String, when: SQLTriggerWhen, event: SQLTriggerEvent) -> SQLCreateTriggerBuilder {
        self.create(trigger: SQLIdentifier(trigger), table: SQLIdentifier(table), when: when, event: event)
    }

    /// Create a new ``SQLCreateTriggerBuilder``.
    @inlinable
    public func create(trigger: any SQLExpression, table: any SQLExpression, when: any SQLExpression, event: any SQLExpression) -> SQLCreateTriggerBuilder {
        .init(trigger: trigger, table: table, when: when, event: event, on: self)
    }
}

