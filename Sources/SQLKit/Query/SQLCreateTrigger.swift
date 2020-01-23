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
    public var procedure: SQLExpression

    /// The MySQL account to be used when checking access privileges at trigger activation time.
    /// Use 'user_name'@'host_name', CURRENT_USER, or CURRENT_USER()
    public var definer: SQLExpression?

    /// The trigger body to execute for dialects that support it.
    public var body: [SQLExpression]?

    public init(trigger: SQLExpression, table: SQLExpression, procedure: SQLExpression, when: SQLExpression, event: SQLExpression) {
        self.name = trigger
        self.table = table
        self.procedure = procedure
        self.when = when
        self.event = event
        self.isConstraint = false
    }

    public init(trigger: String, table: String, procedure: String, when: SQLTriggerWhen, event: SQLTriggerEvent) {
        self.init(trigger: SQLIdentifier(trigger), table: SQLIdentifier(table), procedure: SQLIdentifier(procedure), when: when, event: event)
    }

    private func serializeMySql(_ serializer: inout SQLSerializer) {
        serializer.statement { statement in
            statement.append("CREATE")

            if let definer = definer {
                statement.append("DEFINER = ")
                statement.append(definer)
            }

            statement.append("TRIGGER")
            statement.append(self.name)
            statement.append(when)
            statement.append(event)
            statement.append("ON")
            statement.append(table)
            statement.append("FOR EACH ROW")

            guard let body = body else {
                fatalError("MySQL must define a trigger body")
            }

            body.forEach { statement.append($0) }
        }
    }

    private func serializePostgreSql(_ serializer: inout SQLSerializer) {
        serializer.statement { statement in
            if let when = self.when as? SQLTriggerWhen, when == .instead {
                if let event = self.event as? SQLTriggerEvent, event == .update && columns != nil {
                    fatalError("INSTEAD OF UPDATE events do not support lists of columns")
                }

                if let each = each as? SQLTriggerEach, each != .row {
                    fatalError("INSTEAD OF triggers must be FOR EACH ROW")
                }
            }

            statement.append("CREATE")

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
            } else if self.referencedTable != nil {
                fatalError("referencedTable may only be specified on CONSTRAINT triggers.")
            }

            statement.append("TRIGGER")
            statement.append(self.name)
            statement.append(self.when)
            statement.append(self.event)

            if let columns = self.columns, !columns.isEmpty {
                if let event = self.event as? SQLTriggerEvent {
                    guard event == .update else {
                        fatalError("Only UPDATE triggers may specify a list of columns.")
                    }

                    if let when = self.when as? SQLTriggerWhen, when == .instead {
                        fatalError("INSTEAD OF UPDATE triggers do not support lists of columns.")
                    }
                }

                statement.append("OF")
                statement.append(SQLList(columns))
            }

            statement.append("ON")
            statement.append(self.table)

            if let referencedTable = self.referencedTable {
                statement.append("FROM")
                statement.append(referencedTable)
            }

            if let timing = self.timing {
                guard self.isConstraint else {
                    fatalError("May only specify SQLTriggerTiming on CONSTRAINT triggers.")
                }

                statement.append(timing)
            }

            if let each = self.each {
                statement.append(each)
            } else if isConstraint {
                statement.append(SQLTriggerEach.row)
            }

            if let condition = self.condition {
                if let when = self.when as? SQLTriggerWhen, when == .instead {
                    fatalError("INSTEAD OF triggers do not support WHEN conditions")
                }

                statement.append("WHEN")
                statement.append(SQLGroupExpression(condition))
            }

            statement.append("EXECUTE PROCEDURE")
            statement.append(self.procedure)
        }
    }

    public func serialize(to serializer: inout SQLSerializer) {
        switch serializer.database.dialect.name {
        case "postgresql":
            serializePostgreSql(&serializer)
        case "mysql":
            serializeMySql(&serializer)
        default:
            fatalError("TRIGGERS only supported in MySQL and PostgreSQL so far.")
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
