/// An action to take when an `INSERT` query encounters a unique constraint violation.
///
/// - Note: This is one of the only types at this layer which is _not_ an `SQLExpression`.
///   This is down to the unfortunate fact that while PostgreSQL and SQLite both support the
///   standard's straightforward `ON CONFLICT DO NOTHING` syntax which goes in the same place
///   in the query as an update action would, MySQL can only express the `noAction` case
///   with `INSERT IGNORE`. This requires considering the conflict action twice in the same
///   query when serializing, and to decide what to emit in either location based on both
///   the specific action _and_ the dialect's supported sybtax. As a result, the logic for
///   this has to live in ``SQLInsert``, and it is not possible to serialize a conflict action
///   to SQL in isolation (but again, _only_ because MySQL couldn't be bothered), and this
///   enum can not conform to ``SQLExpression``.
public enum SQLConflictAction {
    /// Specifies that conflicts this action is applied to should be ignored, allowing the query to complete
    /// successfully without inserting any new rows or changing any existing rows.
    case noAction
    
    /// Specifies that conflicts this action is applied to shall cause the INSERT to be converted to an UPDATE
    /// on the same schema which performs the column updates specified by the associated column assignments and,
    /// where supported by the database, constrained by the associated predicate. The column assignments may
    /// include ``SQLExcludedColumn`` expressions to refer to values which would have been inserted into the row
    /// if the conflict had not taken place.
    case update(assignments: [any SQLExpression], predicate: (any SQLExpression)?)
}
