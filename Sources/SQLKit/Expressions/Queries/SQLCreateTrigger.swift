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
    public init(trigger: String, table: String, when: WhenSpecifier, event: EventSpecifier) {
        self.init(trigger: SQLIdentifier(trigger), table: SQLIdentifier(table), when: when, event: event)
    }

    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        let syntax = serializer.dialect.triggerSyntax.create
        let when = self.when as? WhenSpecifier, event = self.event as? EventSpecifier, each = self.each as? EachSpecifier
        
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
        assert(syntax.contains(.supportsDefiner) || self.definer == nil, "Must not specify a definer when dialect does not support it.")
        assert(!syntax.contains(.supportsBody) || self.body != nil, "Must define a trigger body.")
        assert(syntax.contains(.supportsBody) || self.procedure != nil, "Must define a trigger procedure.")

        serializer.statement {
            $0.append("CREATE")
            if syntax.contains(.supportsConstraints), self.isConstraint { $0.append("CONSTRAINT") }
            $0.append("TRIGGER", self.name)
            if let definer = self.definer, syntax.contains(.supportsDefiner) {
                $0.append("DEFINER = ", definer)
            }
            $0.append(self.when)
            $0.append(self.event)
            if let columns = self.columns, !columns.isEmpty, syntax.contains(.supportsUpdateColumns) { $0.append("OF", SQLList(columns)) }
            $0.append("ON", self.table)
            if let referencedTable = self.referencedTable, syntax.contains(.supportsConstraints) { $0.append("FROM", referencedTable) }
            if let timing = self.timing, syntax.contains(.supportsConstraints) { $0.append(timing) }
            if syntax.contains(.requiresForEachRow) || (syntax.isSuperset(of: [.supportsForEach, .supportsConstraints]) && self.isConstraint) {
                $0.append(EachSpecifier.row)
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

    /// A trivial syntactical expression used in constructing `CREATE TRIGGER` queries.
    public enum WhenSpecifier: String, SQLExpression {
        case before = "BEFORE"
        case after = "AFTER"
        case instead = "INSTEAD OF"

        @inlinable
        public func serialize(to serializer: inout SQLSerializer) { serializer.write(self.rawValue) }
    }

    /// A trivial syntactical expression used in constructing `CREATE TRIGGER` queries.
    public enum EventSpecifier: String, SQLExpression {
        case insert = "INSERT"
        case update = "UPDATE"
        case delete = "DELETE"
        case truncate = "TRUNCATE"

        @inlinable
        public func serialize(to serializer: inout SQLSerializer) { serializer.write(self.rawValue) }
    }

    /// A trivial syntactical expression used in constructing `CREATE TRIGGER` queries.
    public enum TimingSpecifier: String, SQLExpression {
        case deferrable = "DEFERRABLE"
        case notDeferrable = "NOT DEFERRABLE"
        case initiallyImmediate = "INITIALLY IMMEDIATE"
        case initiallyDeferred = "INITIALLY DEFERRED"

        @inlinable
        public func serialize(to serializer: inout SQLSerializer) { serializer.write(self.rawValue) }
    }

    /// A trivial syntactical expression used in constructing `CREATE TRIGGER` queries.
    public enum EachSpecifier: String, SQLExpression {
        case row = "FOR EACH ROW"
        case statement = "FOR EACH STATEMENT"

        @inlinable
        public func serialize(to serializer: inout SQLSerializer) { serializer.write(self.rawValue) }
    }

    /// A trivial syntactical expression used in constructing `CREATE TRIGGER` queries.
    public enum OrderSpecifier: String, SQLExpression {
        case follows = "FOLLOWS"
        case precedes = "PRECEDES"

        @inlinable
        public func serialize(to serializer: inout SQLSerializer) { serializer.write(self.rawValue) }
    }
}

/// Old name for ``SQLCreateTrigger/WhenSpecifier``.
@available(*, deprecated, renamed: "SQLCreateTrigger.WhenSpecifier")
public typealias SQLTriggerWhen = SQLCreateTrigger.WhenSpecifier

/// Old name for ``SQLCreateTrigger/EventSpecifier``.
@available(*, deprecated, renamed: "SQLCreateTrigger.EventSpecifier")
public typealias SQLTriggerEvent = SQLCreateTrigger.EventSpecifier

/// Old name for ``SQLCreateTrigger/TimingSpecifier``.
@available(*, deprecated, renamed: "SQLCreateTrigger.TimingSpecifier")
public typealias SQLTriggerTiming = SQLCreateTrigger.TimingSpecifier

/// Old name for ``SQLCreateTrigger/EachSpecifier``.
@available(*, deprecated, renamed: "SQLCreateTrigger.EachSpecifier")
public typealias SQLTriggerEach = SQLCreateTrigger.EachSpecifier

/// Old name for ``SQLCreateTrigger/OrderSpecifier``.
@available(*, deprecated, renamed: "SQLCreateTrigger.OrderSpecifier")
public typealias SQLTriggerOrder = SQLCreateTrigger.OrderSpecifier
