/// General locking expressions for a SQL locking clause.
///
///     SELECT ... FOR UPDATE
///
/// See `SQLSelectBuilder.for` and `SQLSelect.lockingClause`.
public enum SQLLockingClause: SQLExpression {
    /// `UPDATE`
    case update
    
    /// `SHARE`
    case share
    
    /// See `SQLExpression`.
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .share:
            serializer.write("SHARE")
        case .update:
            serializer.write("UPDATE")
        }
    }
}
