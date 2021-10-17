/// Specifies a conflict resolution strategy and associated conditions for an `INSERT` query.
/// An `INSERT` with a conflict strategy is often refered to as an `UPSERT` ("insert or update").
/// Databases are not required to support any given subset of upsert functionality, or any at all.
///
/// Unfortunately, in MySQL the "no action" strategy must use `INSERT IGNORE` and deal with that
/// being a different clause of the query than any of the other strategies. For now that's
/// implemented by using two "related" expressions which both check whether to emit. SQLKit doesn't
/// do well with this kind of syntax difference; there has not been a previous need.
///
/// It is our most fervent hope for a future in which MySQL finally provides more compliant syntax
/// (or refuses for good), and gets promptly squashed by the giant foot from Monty Python (and a
/// classic System 7 AV utility's About dialog), leaving PostgreSQL free to take over the world at last.
public struct SQLConflictResolutionStrategy: SQLExpression {
    /// The column or columns the strategy applies to. Must have uniqueness constraints.
    /// One or more columns are always required even if the underlying database ignores them.
    public var targetColumns: [SQLExpression]
    
    /// An action to take to resolve a conflict in one of the target columns. See `SQLConflictAction`.
    public var action: SQLExpression
    
    /// Create a resolution strategy over the given column names and an action.
    public init(targets targetColumns: [String], action: SQLConflictAction) {
        self.init(targets: targetColumns.map { SQLColumn($0) }, action: SQLConflictActionExpression(action: action))
    }
    
    /// Create a resolution strategy over the given columns and an action.
    public init(targets targetColumns: [SQLExpression], action: SQLConflictAction) {
        self.init(targets: targetColumns, action: SQLConflictActionExpression(action: action))
    }
    
    /// Create a resolution strategy over the given column names and an action expression.
    public init(targets targetColumns: [String], action: SQLExpression) {
        self.init(targets: targetColumns.map { SQLColumn($0) }, action: action)
    }
    
    /// Create a resolution strategy over the given columns and an action expression.
    public init(targets targetColumns: [SQLExpression], action: SQLExpression) {
        self.targetColumns = targetColumns
        self.action = action
    }
    
    /// An expression to be embedded into the same `INSERT` query as the stratey expression to
    /// work around MySQL's desire to make life difficult.
    public var queryModifier: SQLInsertModifier { .init(action: self.action) }

    /// See `SQLSerializer.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            // Bail if no upsert support, no upsert action, or it's MySQL's special case (MySQL syntax w/ noAction).
            guard $0.dialect.upsertSyntax != .unsupported, self.action.isDefaultConflictAction,
                  ($0.dialect.upsertSyntax != .mysqlLike || self.action.isIgnoreConflictAction)
            else { return }
            
            assert(!self.targetColumns.isEmpty, "Conflict resolution reuires at least one target column.")
            
            if $0.dialect.upsertSyntax == .standard { $0.append("ON CONFLICT", SQLGroupExpression(self.targetColumns)) }
            $0.append(self.action)
        }
    }
}

/// Simple helper for working around MySQL's refusal to implement standard SQL. Only emits SQL when needed.
public struct SQLInsertModifier: SQLExpression {
    /// The conflict action from the original resolution strategy.
    public var action: SQLExpression

    /// See `SQLSerializer.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            if $0.dialect.upsertSyntax == .mysqlLike, self.action.isIgnoreConflictAction { $0.append("IGNORE") }
        }
    }
}

/// A wrapper that adds `SQLExpression` to `SQLConflictAction`. Done this way to keep the conformance
/// from being publicly visible, since it's unsafe to use except where needed.
struct SQLConflictActionExpression: SQLExpression {
    var action: SQLConflictAction

    func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            // Assumes that the various preconditions, like skipping for the default action etc., are already checked.
            switch ($0.dialect.upsertSyntax, self.action) {
            case (.standard, .noAction):
                $0.append("DO NOTHING")
            
            case (.standard, .update(let assignments, let predicate)):
                assert(!assignments.isEmpty, "Must specify at least one column for updates; consider using noAction instead.")
                $0.append("DO UPDATE SET", SQLList(assignments))
                if let predicate = predicate { $0.append("WHERE", predicate) }
            
            case (.mysqlLike, .update(let assignments, _)):
                assert(!assignments.isEmpty, "Must specify at least one column for updates; consider using noAction instead.")
                $0.append("ON DUPLICATE KEY UPDATE", SQLList(assignments))
            
            default:
                preconditionFailure("SQLConflictAction's preconditions violated; wrong dialect or action - THIS IS A BUG IN FLUENT")
            }
        }
    }
}

extension SQLExpression {
    var isDefaultConflictAction: Bool { (self as? SQLConflictActionExpression).map { if case .default = $0.action { return true }; return false } ?? false }
    var isIgnoreConflictAction: Bool { (self as? SQLConflictActionExpression).map { if case .noAction = $0.action { return true }; return false } ?? false }
}
