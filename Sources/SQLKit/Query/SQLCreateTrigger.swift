/// The `CREATE TRIGGER` command is used to create a trigger against a table.
///
/// See ``SQLCreateTriggerBuilder``.
public struct SQLCreateTrigger: SQLExpression {
    /// Name of the trigger to create.
    public var name: any SQLExpression

    /// The table which uses the trigger.
    public var table: any SQLExpression

    /// The column(s) which are watched by the trigger.
    public var columns: [any SQLExpression]?

    /// Whether or not this is a `CONSTRAINT` trigger.
    public var isConstraint: Bool

    /// When the trigger should run.
    public var when: any SQLExpression

    /// The event which causes the trigger to execute.
    public var event: any SQLExpression

    /// The timing of the tirgger.  This can only be specified for constraint triggers.
    public var timing: (any SQLExpression)?

    /// Used for foreign key constraints and is not recommended for general use.
    public var referencedTable: (any SQLExpression)?

    /// Whether the trigger is fired: once for every row or just once per SQL statement.
    public var each: (any SQLExpression)?

    /// The condition as to when the trigger should be fired.
    public var condition: (any SQLExpression)?

    /// The name of the function which must take no arguments and return a `TRIGGER` type.
    public var procedure: (any SQLExpression)?

    /// The MySQL account to be used when checking access privileges at trigger activation time.
    /// Use `'user_name'@'host_name'`, `CURRENT_USER`, or `CURRENT_USER()`
    public var definer: (any SQLExpression)?

    /// The trigger body to execute for dialects that support it.
    /// - Note: You should **not** include `BEGIN`/`END` statements.  They are added automatically.
    public var body: [any SQLExpression]?

    /// A ``SQLTriggerOrder`` used by MySQL
    public var order: (any SQLExpression)?

    /// The other trigger name for for the ``order``
    public var orderTriggerName: (any SQLExpression)?

    @inlinable
    public init(trigger: any SQLExpression, table: any SQLExpression, when: any SQLExpression, event: any SQLExpression) {
        self.name = trigger
        self.table = table
        self.when = when
        self.event = event
        self.isConstraint = false
    }

    @inlinable
    public init(trigger: String, table: String, when: SQLTriggerWhen, event: SQLTriggerEvent) {
        self.init(trigger: SQLIdentifier(trigger), table: SQLIdentifier(table), when: when, event: event)
    }

    public func serialize(to serializer: inout SQLSerializer) {
        let syntax = serializer.dialect.triggerSyntax.create
        let when = self.when as? SQLTriggerWhen, event = self.event as? SQLTriggerEvent, each = self.each as? SQLTriggerEach
        
        if syntax.contains(.postgreSQLChecks) {
            assert(when != .instead || event != .update || self.columns == nil, "INSTEAD OF UPDATE events do not support lists of columns")
            assert(when != .instead || each == .row, "INSTEAD OF triggers must be FOR EACH ROW")
            assert(!syntax.contains(.supportsUpdateColumns) || (columns?.isEmpty ?? true) || event != .update, "Only UPDATE triggers may specify a list of columns.")
            assert(!syntax.contains(.supportsCondition) || when != .instead || self.condition == nil, "INSTEAD OF triggers do not support WHEN conditions.")
            if syntax.contains(.supportsConstraints) {
                assert(!self.isConstraint || when == .after, "CONSTRAINT triggers may only be SQLTriggerWhen.after")
                assert(!self.isConstraint || each == .row, "CONSTRAINT triggers may only be specified FOR EACH ROW")
                assert(self.isConstraint || self.timing == nil, "May only specify SQLTriggerTiming on CONSTRAINT triggers.")
            }
        }
        assert(!syntax.contains(.supportsBody) || self.body != nil, "Must define a trigger body.")
        assert(syntax.contains(.supportsBody) || self.procedure != nil, "Must define a trigger procedure.")

        serializer.statement {
            $0.append("CREATE")
            if syntax.contains(.supportsConstraints), self.isConstraint { $0.append("CONSTRAINT") }
            $0.append("TRIGGER", self.name)
            $0.append(self.when)
            $0.append(self.event)
            if let columns = self.columns, !columns.isEmpty, syntax.contains(.supportsUpdateColumns) { $0.append("OF", SQLList(columns)) }
            $0.append("ON", self.table)
            if let referencedTable = self.referencedTable, syntax.contains(.supportsConstraints) { $0.append("FROM", referencedTable) }
            if let timing = self.timing, syntax.contains(.supportsConstraints) { $0.append(timing) }
            if syntax.contains(.requiresForEachRow) || (syntax.isSuperset(of: [.supportsForEach, .supportsConstraints]) && self.isConstraint) {
                $0.append(SQLTriggerEach.row)
            } else if syntax.contains(.supportsForEach), let each = self.each {
                $0.append(each)
            }
            if let condition = self.condition, syntax.contains(.supportsCondition) {
                $0.append("WHEN", syntax.contains(.conditionRequiresParentheses) ? SQLGroupExpression(condition) : condition)
            }
            if let order = self.order, let orderTriggerName = self.orderTriggerName, syntax.contains(.supportsOrder) {
                $0.append(order)
                $0.append(orderTriggerName)
            }
            if syntax.contains(.supportsBody), let body = self.body {
                $0.append("BEGIN")
                $0.append(SQLList(body, separator: SQLRaw(" ")))
                $0.append("END;")
            } else if let procedure = self.procedure {
                $0.append("EXECUTE PROCEDURE", procedure)
            }
        }
    }
}

public enum SQLTriggerWhen: SQLExpression {
    case before
    case after
    case instead

    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .before:  serializer.write("BEFORE")
        case .after:   serializer.write("AFTER")
        case .instead: serializer.write("INSTEAD OF")
        }
    }
}

public enum SQLTriggerEvent: SQLExpression {
    case insert
    case update
    case delete
    case truncate

    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .insert:   serializer.write("INSERT")
        case .update:   serializer.write("UPDATE")
        case .delete:   serializer.write("DELETE")
        case .truncate: serializer.write("TRUNCATE")
        }
    }
}

public enum SQLTriggerTiming: SQLExpression {
    case deferrable
    case notDeferrable
    case initiallyImmediate
    case initiallyDeferred

    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .deferrable:         serializer.write("DEFERRABLE")
        case .notDeferrable:      serializer.write("NOT DEFERRABLE")
        case .initiallyImmediate: serializer.write("INITIALLY IMMEDIATE")
        case .initiallyDeferred:  serializer.write("INITIALLY DEFERRED")
        }
    }
}

public enum SQLTriggerEach: SQLExpression {
    case row
    case statement

    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .row:       serializer.write("FOR EACH ROW")
        case .statement: serializer.write("FOR EACH STATEMENT")
        }
    }
}

public enum SQLTriggerOrder: SQLExpression {
    case follows
    case precedes

    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .follows:  serializer.write("FOLLOWS")
        case .precedes: serializer.write("PRECEDES")
        }
    }
}
