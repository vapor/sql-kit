/// General locking expressions for a SQL locking clause. The actual locking clause syntax
/// for any given SQL dialect is defined by the dialect.
///
///     SELECT ... FOR UPDATE
///
/// See ``SQLSubqueryClauseBuilder/for(_:)`` and ``SQLSelect/lockingClause``.
public enum SQLLockingClause: SQLExpression {
    /// Request an exclusive "writer" lock.
    case update
    
    /// Request a shared "reader" lock.
    case share
    
    /// See ``SQLExpression/serialize(to:)``.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            switch self {
            case .share: $0.append($0.dialect.sharedSelectLockExpression)
            case .update: $0.append($0.dialect.exclusiveSelectLockExpression)
            }
        }
    }
}
