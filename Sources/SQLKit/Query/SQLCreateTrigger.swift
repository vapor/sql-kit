/// The `CREATE TRIGGER` command is used to create a trigger against a table
///
/// See `SQLCreateTribberBuilder`
public struct SQLCreateTrigger: SQLExpression {
    /// Name of the trigger to create.
    public var name: SQLExpression

    /// The table which uses the trigger.
    public var table: SQLExpression

    /// The column(s) which are watched by the trigger
    public var columns: [SQLExpression]?

    /// Whether or not this is a CONSTRAINT trigger.
    public var isConstraint: Bool

    /// When the trigger should run.
    public var when: SQLExpression

    /// The event which causes the trigger to execute.
    public var event: SQLExpression

    /// The timing of the tirgger.  This can only be specified for constraint triggers
    public var timing: SQLExpression?

    /// Used for foreign key constraints and is not recommended for general use.
    public var referencedTable: SQLExpression?

    /// Whether the trigger is fired: once for every row or just once per SQL statement.
    public var each: SQLExpression?

    /// The condition as to when the trigger should be fired.
    public var condition: SQLExpression?

    /// The name of the function which must take no arguments and return a TRIGGER type.
    public var procedure: SQLExpression?

    /// The MySQL account to be used when checking access privileges at trigger activation time.
    /// Use 'user_name'@'host_name', CURRENT_USER, or CURRENT_USER()
    public var definer: SQLExpression?

    /// The trigger body to execute for dialects that support it.
    /// - Note: You should **not** include BEGIN/END statements.  They are added automatically.
    public var body: [SQLExpression]?

    /// A `SQLTriggerOrder` used by MySQL
    public var order: SQLExpression?

    /// The other trigger name for for the `order`
    public var orderTriggerName: SQLExpression?

    public init(trigger: SQLExpression, table: SQLExpression, when: SQLExpression, event: SQLExpression) {
        self.name = trigger
        self.table = table
        self.when = when
        self.event = event
        self.isConstraint = false
    }

    public init(trigger: String, table: String, when: SQLTriggerWhen, event: SQLTriggerEvent) {
        self.init(trigger: SQLIdentifier(trigger), table: SQLIdentifier(table), when: when, event: event)
    }

    public func serialize(to serializer: inout SQLSerializer) {
        let triggerCreateSyntax = serializer.dialect.triggerSyntax.create

        serializer.statement { statement in
            if triggerCreateSyntax.contains(.postgreSQLChecks), let when = self.when as? SQLTriggerWhen, when == .instead {
                if let event = self.event as? SQLTriggerEvent, event == .update && columns != nil {
                    fatalError("INSTEAD OF UPDATE events do not support lists of columns")
                }

                if let each = each as? SQLTriggerEach, each != .row {
                    fatalError("INSTEAD OF triggers must be FOR EACH ROW")
                }
            }

            statement.append("CREATE")

            if triggerCreateSyntax.contains(.supportsConstraints) {
                if self.isConstraint {
                    if let when = self.when as? SQLTriggerWhen, when != .after {
                        fatalError("CONSTRAINT triggers may only be SQLTriggerWhen.after")
                    }

                    // This goofy looking double-if is because it could exist but be a SQLExpression
                    if self.each != nil {
                        if let eachEnum = self.each as? SQLTriggerEach, eachEnum != .row {
                            fatalError("CONSTRAINT triggers may only be specified FOR EACH ROW")
                        }
                    }

                    statement.append("CONSTRAINT")
                }
            }

            statement.append("TRIGGER")
            statement.append(self.name)
            statement.append(self.when)
            statement.append(self.event)

            if let columns = self.columns, !columns.isEmpty, triggerCreateSyntax.contains(.supportsUpdateColumns) {
                if triggerCreateSyntax.contains(.postgreSQLChecks) {
                    if let event = self.event as? SQLTriggerEvent {
                        guard event == .update else {
                            fatalError("Only UPDATE triggers may specify a list of columns.")
                        }

                        if let when = self.when as? SQLTriggerWhen, when == .instead {
                            fatalError("INSTEAD OF UPDATE triggers do not support lists of columns.")
                        }
                    }
                }

                statement.append("OF")
                statement.append(SQLList(columns))
            }

            statement.append("ON")
            statement.append(self.table)

            if let referencedTable = self.referencedTable, triggerCreateSyntax.contains(.supportsConstraints) {
                statement.append("FROM")
                statement.append(referencedTable)
            }

            if let timing = self.timing, triggerCreateSyntax.contains(.supportsConstraints) {
                guard self.isConstraint else {
                    fatalError("May only specify SQLTriggerTiming on CONSTRAINT triggers.")
                }

                statement.append(timing)
            }

            if triggerCreateSyntax.contains(.requiresForEachRow) {
                statement.append(SQLTriggerEach.row)
            } else if triggerCreateSyntax.contains(.supportsForEach) {
                if triggerCreateSyntax.contains(.supportsConstraints), isConstraint {
                    statement.append(SQLTriggerEach.row)
                } else if let each = self.each {
                    statement.append(each)
                } 
            }

            if let condition = self.condition, triggerCreateSyntax.contains(.supportsCondition) {
                if let when = self.when as? SQLTriggerWhen, when == .instead, triggerCreateSyntax.contains(.postgreSQLChecks) {
                    fatalError("INSTEAD OF triggers do not support WHEN conditions.")
                }

                statement.append("WHEN")

                let cond = triggerCreateSyntax.contains(.conditionRequiresParentheses) ? SQLGroupExpression(condition) : condition
                statement.append(cond)
            }

            if let order = order, let orderTriggerName = orderTriggerName, triggerCreateSyntax.contains(.supportsOrder) {
                statement.append(order)
                statement.append(orderTriggerName)
            }

            if triggerCreateSyntax.contains(.supportsBody) {
                guard let body = body else {
                    fatalError("Must define a trigger body.")
                }

                statement.append("BEGIN")
                body.forEach { statement.append($0) }
                statement.append("END;")
            } else {
                guard let procedure = procedure else {
                    fatalError("Must define a trigger procedure.")
                }

                statement.append("EXECUTE PROCEDURE")
                statement.append(procedure)
            }
        }
    }
}

public enum SQLTriggerWhen: SQLExpression {
    case before
    case after
    case instead

    public func serialize(to serializer: inout SQLSerializer) {
        let str: String

        switch self {
        case .before:
            str = "BEFORE"
        case .after:
            str = "AFTER"
        case .instead:
            str = "INSTEAD OF"
        }

        SQLRaw(str).serialize(to: &serializer)
    }
}

public enum SQLTriggerEvent: SQLExpression {
    case insert
    case update
    case delete
    case truncate

    public func serialize(to serializer: inout SQLSerializer) {
        let str: String

        switch self {
        case .insert:
            str = "INSERT"
        case .update:
            str = "UPDATE"
        case .delete:
            str = "DELETE"
        case .truncate:
            str = "TRUNCATE"
        }

        SQLRaw(str).serialize(to: &serializer)
    }
}

public enum SQLTriggerTiming: SQLExpression {
    case deferrable
    case notDeferrable
    case initiallyImmediate
    case initiallyDeferred

    public func serialize(to serializer: inout SQLSerializer) {
        let str: String

        switch self {
        case .deferrable:
            str = "DEFERRABLE"
        case .notDeferrable:
            str = "NOT DEFERRABLE"
        case .initiallyImmediate:
            str = "INITIALLY IMMEDIATE"
        case .initiallyDeferred:
            str = "INITIALLY DEFERRED"
        }

        SQLRaw(str).serialize(to: &serializer)
    }
}

public enum SQLTriggerEach: SQLExpression {
    case row
    case statement

    public func serialize(to serializer: inout SQLSerializer) {
        let str: String

        switch self {
        case .row:
            str = "ROW"
        case .statement:
            str = "STATEMENT"
        }

        SQLRaw("FOR EACH \(str)").serialize(to: &serializer)
    }
}

public enum SQLTriggerOrder: SQLExpression {
    case follows
    case precedes

    public func serialize(to serializer: inout SQLSerializer) {
        let str: String

        switch self {
        case .follows: str = "FOLLOWS"
        case .precedes: str = "PRECEDES"
        }

        SQLRaw(str).serialize(to: &serializer)
    }
}
