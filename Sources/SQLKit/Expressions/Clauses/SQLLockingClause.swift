/// An SQL locking clause.
///
/// A locking clause is an optional clause added to a `SELECT` query to specify an additional locking mode for rows
/// matched by the query, most often to improve performance when multiple transactions access and/or update the same
/// data simultaneously.
///
/// The actual syntax for a locking clause is provided by the database's dialect; when a dialect doesn't support a
/// particular type of lock (or none at all), this expression generates no serialized output.
///
/// See ``SQLSubqueryClauseBuilder/for(_:)`` and ``SQLSelect/lockingClause``.
public enum SQLLockingClause: SQLExpression {
    /// Request an exclusive "writer" lock.
    case update
    
    /// Request a shared "reader" lock.
    case share
    
    // See `SQLExpression.serialize(to:)`.
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
