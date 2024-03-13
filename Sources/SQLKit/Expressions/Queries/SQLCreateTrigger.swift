/// An expression representing a `CREATE TRIGGER` query. Used to create new triggers for actions on a table.
///
/// ```sql
/// CREATE CONSTRAINT TRIGGER "trigger"
///     DEFINER=foo
///     AFTER UPDATE OF "column1", "column2" ON "table"
///     FROM "other_table" NOT DEFERRABLE
///     FOR EACH ROW
///     WHEN ("column3"="four")
///     FOLLOWS "other_trigger"
/// BEGIN
///     ...
/// END;
/// ```
///
/// When used with the PostgreSQL driver, ``SQLCreateTrigger`` performs strong validation of its properties with
/// respect to PostgreSQL's syntax restrictions. In general, the dialect specifies in granular detail exactly which
/// features it supports; properties specifying features not supported by the dialect are generally ignored, except
/// with respect to the trigger body/procedure and the definer (if specified), which are validated by assertion (a
/// runtime error results from invalid use in debug builds, whereas invalid syntax is silently emitted in release
/// builds so that the database will report the issue).
///
/// See ``SQLCreateTriggerBuilder``.
public struct SQLCreateTrigger: SQLExpression {
    /// The name for the new trigger.
    public var name: any SQLExpression

    /// The table the new trigger is applied to.
    public var table: any SQLExpression

    /// A list of zero or more columns to which the trigger is applied, if supported.
    ///
    /// The optionality of this property is an API design flaw. Both `nil` and an empty array are treated identically,
    /// indicating that the trigger applies to all columns.
    public var columns: [any SQLExpression]?

    /// `true` if the new trigger will be a constraint trigger, if supported.
    public var isConstraint: Bool

    /// The ordering of the trigger's execution relative to the triggering event.
    ///
    /// See ``SQLCreateTrigger/WhenSpecifier``. If set to any other type of expression, validity checking is skipped.
    public var when: any SQLExpression

    /// The event the trigger watches for.
    ///
    /// See ``SQLCreateTrigger/EventSpecifier``. If set to any other type of expression, validity checking is skipped.
    public var event: any SQLExpression

    /// The deferability status of a constraint trigger with respect to the triggering event, if not `nil`.
    ///
    /// This can only be specified for constraint triggers, and is ignored otherwise.
    ///
    /// See ``SQLCreateTrigger/TimingSpecifier``.
    public var timing: (any SQLExpression)?

    /// Specifies a table referenced by a foreign key constraint for a constraint trigger, if not `nil`.
    ///
    /// The use of this functionality is not recommended, and is ignored on non-contraint triggers.
    public var referencedTable: (any SQLExpression)?

    /// When supported, describes whether the trigger executes on a per-row or per-statement basis.
    ///
    /// Even when this is left as `nil`, `FOR EACH ROW` may be emitted anyway if the dialect requires it.
    ///
    /// See ``SQLCreateTrigger/EachSpecifier``. If set to any other type of expression, validity checking is skipped.
    public var each: (any SQLExpression)?

    /// A predicate determining whether the trigger should execute for a given event, if supported.
    public var condition: (any SQLExpression)?

    /// The name of a pre-existing stored procedure to invoke as the body of the trigger.
    ///
    /// This is a stored procedure in the SQL sense, a routine defined by a `CREATE PROCEDURE` query. Either this
    /// property or ``body`` must be non-`nil`, and most dialects only support one or the other.
    public var procedure: (any SQLExpression)?

    /// If supported by dialect, a user or role to be treated as the trigger's owner for purposes of determining the
    /// privileges available to the trigger's body.
    ///
    /// Currently only supported by MySQL.
    public var definer: (any SQLExpression)?

    /// One or more expressions containing procedural SQL statements in the syntax supported by the dialect.
    ///
    /// That this is an array is an API design flaw; the expressions in the array, if any, are joined with space
    /// characters and the result is used as the body. It is recommended to use ``SQLQueryString`` to generate
    /// an appropriate expression. Either this property or ``procedure``  must be non-`nil`, and most dialects only
    /// support one or the other.
    ///
    /// > Note: The body should not include `BEGIN`/`END` statements, regardless of dialect.
    public var body: [any SQLExpression]?

    /// Specifies the order of the new trigger with regards to another trigger, in concert with ``orderTriggerName``.
    ///
    /// If `nil` or unsupported, ``orderTriggerName`` is ignored.
    ///
    /// > Note: The order and the name to apply it to being separate properties is yet another API designf law.
    public var order: (any SQLExpression)?

    /// When ``order`` is not `nil`, specifies the name of the trigger to which the ordering will apply.
    ///
    /// If ``order`` is not `nil`, but this property is, ``order`` is ignored.
    ///
    /// See ``SQLCreateTrigger/OrderSpecifier``.
    ///
    /// > Note: The order and the name to apply it to being separate properties is yet another API design flaw.
    public var orderTriggerName: (any SQLExpression)?

    /// Create a new trigger creation query.
    ///
    /// - Parameters:
    ///   - trigger: The name for the new trigger.
    ///   - table: The table to which the new trigger is attached.
    ///   - when: Specifies when the trigger runs relative to the triggering event.
    ///     See ``SQLCreateTrigger/WhenSpecifier``.
    ///   - event: Specifies the triggering event for the trigger. See ``SQLCreateTrigger/EventSpecifier``.
    @inlinable
    public init(trigger: any SQLExpression, table: any SQLExpression, when: any SQLExpression, event: any SQLExpression) {
        self.name = trigger
        self.table = table
        self.when = when
        self.event = event
        self.isConstraint = false
    }

    /// Create a new trigger creation query.
    ///
    /// - Parameters:
    ///   - trigger: The name for the new trigger.
    ///   - table: The table to which the new trigger is attached.
    ///   - when: Specifies when the trigger runs relative to the triggering event.
    ///     See ``SQLCreateTrigger/WhenSpecifier``.
    ///   - event: Specifies the triggering event for the trigger. See ``SQLCreateTrigger/EventSpecifier``.
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
            assert(!syntax.contains(.supportsUpdateColumns) || (columns?.isEmpty ?? true) || event == .update, "Only UPDATE triggers may specify a list of columns.")
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
            if syntax.contains(.supportsConstraints), self.isConstraint {
                $0.append("CONSTRAINT")
            }
            $0.append("TRIGGER", self.name)
            if let definer = self.definer, syntax.contains(.supportsDefiner) {
                $0.append("DEFINER = ", definer)
            }
            $0.append(self.when, self.event)
            if let columns = self.columns, !columns.isEmpty, syntax.contains(.supportsUpdateColumns) {
                $0.append("OF", SQLList(columns))
            }
            
            $0.append("ON", self.table)
            
            if let referencedTable = self.referencedTable, syntax.contains(.supportsConstraints) {
                $0.append("FROM", referencedTable)
            }
            
            if let timing = self.timing, syntax.contains(.supportsConstraints) {
                $0.append(timing)
            }
            
            if syntax.contains(.requiresForEachRow) || (syntax.isSuperset(of: [.supportsForEach, .supportsConstraints]) && self.isConstraint) {
                $0.append(EachSpecifier.row)
            } else if syntax.contains(.supportsForEach), let each = self.each {
                $0.append(each)
            }
            
            if let condition = self.condition, syntax.contains(.supportsCondition) {
                $0.append("WHEN", syntax.contains(.conditionRequiresParentheses) ? SQLGroupExpression(condition) : condition)
            }
            
            if let order = self.order, let orderTriggerName = self.orderTriggerName, syntax.contains(.supportsOrder) {
                $0.append(order, orderTriggerName)
            }

            if syntax.contains(.supportsBody), let body = self.body {
                $0.append("BEGIN", SQLList(body, separator: SQLRaw(" ")), "END;")
            } else if let procedure = self.procedure {
                $0.append("EXECUTE PROCEDURE", procedure)
            }
        }
    }
}

extension SQLCreateTrigger {
    /// Specifies how a trigger executes relative to the event that triggers it.
    public enum WhenSpecifier: String, SQLExpression {
        /// Run the trigger before the event.
        case before = "BEFORE"
        
        /// Run the trgger after the event.
        case after = "AFTER"
        
        /// Replace the event with the trigger's execution.
        ///
        /// Not supported by all dialects.
        case instead = "INSTEAD OF"

        // See `SQLExpression.serialize(to:)`.
        @inlinable
        public func serialize(to serializer: inout SQLSerializer) {
            serializer.write(self.rawValue)
        }
    }

    /// Specifies an event which causes a trigger to execute.
    public enum EventSpecifier: String, SQLExpression {
        /// Execute the trigger when a row is inserted into the table.
        case insert = "INSERT"
        
        /// Execute the trigger when one or more rows in the table are updated.
        ///
        /// If an `UPDATE` query runs without updating any rows, the trigger is _not_ executed.
        case update = "UPDATE"
        
        /// Execute the trigger when one or more rows in the table are deleted.
        ///
        /// If a `DELETE` query runs without deleting any rows, the trigger is _not_ executed.
        case delete = "DELETE"
        
        /// Execute the trigger when the table is truncated.
        case truncate = "TRUNCATE"

        // See `SQLExpression.serialize(to:)`.
        @inlinable
        public func serialize(to serializer: inout SQLSerializer) {
            serializer.write(self.rawValue)
        }
    }

    /// Specifies the deferability of a contraint trigger vis a vis the associated constraint.
    public enum TimingSpecifier: String, SQLExpression, Equatable {
        /// The trigger's execution may be deferred until the end of the active transaction by
        /// `SET CONSTRAINTS ... DEFERRED`, but runs immediately by default.
        case deferrable = "DEFERRABLE INITIALLY IMMEDIATE"
        
        /// The trigger's execution is deferred until the end of the active transaction unless
        /// changed by `SET CONSTRAINTS ... IMMEDIATE`.
        case deferredByDefault = "DEFERRABLE INITIALLY DEFERRED"
        
        /// The trigger's execution may not be deferred; it always runs immediately.
        case notDeferrable = "NOT DEFERRABLE"
        
        // See `SQLExpression.serialize(to:)`.
        @inlinable
        public func serialize(to serializer: inout SQLSerializer) {
            serializer.write(self.rawValue)
        }
    }

    /// Specifies whether a trigger executes for each row affected by an event or once for each triggering statement.
    public enum EachSpecifier: String, SQLExpression {
        /// Execute the trigger once for each row affected by the statement which triggered it.
        case row = "FOR EACH ROW"
        
        /// Execute the trigger once each time a statement triggers it.
        case statement = "FOR EACH STATEMENT"

        // See `SQLExpression.serialize(to:)`.
        @inlinable
        public func serialize(to serializer: inout SQLSerializer) {
            serializer.write(self.rawValue)
        }
    }

    /// Specifies ordering for a trigger relative to another trigger.
    public enum OrderSpecifier: String, SQLExpression {
        /// The trigger will execute after the specified existing trigger.
        case follows = "FOLLOWS"
        
        /// The trigger will execute before the specified existing trigger.
        case precedes = "PRECEDES"

        // See `SQLExpression.serialize(to:)`.
        @inlinable
        public func serialize(to serializer: inout SQLSerializer) {
            serializer.write(self.rawValue)
        }
    }
}
