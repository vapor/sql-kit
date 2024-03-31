/// Specifies a conflict resolution strategy and associated conditions for an `INSERT` query.
/// An `INSERT` with a conflict strategy is often refered to as an `UPSERT` ("insert or update").
/// Databases are not required to support any given subset of upsert functionality, or any at all.
///
/// Unfortunately, in MySQL the "no action" strategy must use `INSERT IGNORE`, which appears in a
/// completely different place in the query than the update strategy. For now, this is implemented
/// by providing an additional expression that `SQLInsert` has to embed at the appropriate point
/// if provided, which is gated on both the dialect's syntax and the conflict action. There hasn't
/// been a need to deal with this particular kind of syntax issue before, so this method of handling
/// it is something of an experiment.
public struct SQLConflictResolutionStrategy: SQLExpression {
    /// The column or columns which comprise the uniquness constraint to which the strategy
    /// should apply. The exact rules for how a matching constraint is found when an exact
    /// match is not found vary between databases. Not all database implement conflict targets.
    public var targetColumns: [any SQLExpression]
    
    /// An action to take to resolve a conflict in the unique index.
    public var action: SQLConflictAction
    
    /// Create a resolution strategy over the given column name and an action.
    @inlinable
    public init(target targetColumn: String, action: SQLConflictAction) {
        self.init(targets: [targetColumn], action: action)
    }

    /// Create a resolution strategy over the given column names and an action.
    @inlinable
    public init(targets targetColumns: [String], action: SQLConflictAction) {
        self.init(targets: targetColumns.map { SQLColumn($0) }, action: action)
    }
    
    /// Create a resolution strategy over the given column and an action.
    @inlinable
    public init(target targetColumn: any SQLExpression, action: SQLConflictAction) {
        self.init(targets: [targetColumn], action: action)
    }
    
    /// Create a resolution strategy over the given columns and an action.
    @inlinable
    public init(targets targetColumns: [any SQLExpression], action: SQLConflictAction) {
        self.targetColumns = targetColumns
        self.action = action
    }
    
    /// An expression to be embedded into the same `INSERT` query as the strategy expression to
    /// work around MySQL's desire to make life difficult.
    @inlinable
    public func queryModifier(for serializer: SQLSerializer) -> (any SQLExpression)? {
        if serializer.dialect.upsertSyntax == .mysqlLike, case .noAction = self.action {
            return SQLInsertModifier()
        }
        return nil
    }

    // See `SQLSerializer.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            switch ($0.dialect.upsertSyntax, self.action) {
                case (.standard, .noAction):
                    $0.append("ON CONFLICT")
                    if !self.targetColumns.isEmpty {
                        $0.append(SQLGroupExpression(self.targetColumns))
                    }
                    $0.append("DO NOTHING")
                case (.standard, .update(let assignments, let predicate)):
                    assert(!assignments.isEmpty, "Must specify at least one column for updates; consider using noAction instead.")
                    $0.append("ON CONFLICT")
                    if !self.targetColumns.isEmpty {
                        $0.append(SQLGroupExpression(self.targetColumns))
                    }
                    $0.append("DO UPDATE SET", SQLList(assignments))
                    if let predicate = predicate { $0.append("WHERE", predicate) }
                case (.mysqlLike, .noAction):
                    break
                case (.mysqlLike, .update(let assignments, _)):
                    assert(!assignments.isEmpty, "Must specify at least one column for updates; consider using noAction instead.")
                    $0.append("ON DUPLICATE KEY UPDATE", SQLList(assignments))
                case (.unsupported, _):
                    break
            }
        }
    }
}

/// Simple helper for working around MySQL's refusal to implement standard SQL. Only emits SQL when needed.
public struct SQLInsertModifier: SQLExpression {
    @usableFromInline
    init() {}
    
    // See `SQLSerializer.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write("IGNORE")
    }
}
