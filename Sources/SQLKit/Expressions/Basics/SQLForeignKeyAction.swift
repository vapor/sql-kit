/// An expression specifying a behavior for a foreign key constraint violation.
public enum SQLForeignKeyAction: SQLExpression {
    /// The `NO ACTION` behavior.
    ///
    /// `NO ACTION` triggers an SQL error indicating that the operation in progress has violated a foreign
    /// key constraint. For immediate constraints (the default in most systems), the behavior is identical to
    /// ``restrict``. If the violated constraint is deferred, the error is not raised immediately, and the
    /// remainder of the query in progress is given an opportunity to complete and potentially negate the
    /// violation.
    ///
    /// This is the default action.
    case noAction
    
    /// The `RESTRICT` behavior.
    ///
    /// `RESTRICT` triggers an SQL error indicating that the operation in progress has violated a foreign
    /// key constraint. The error is raised immediately, regardless of the deferred status of the constraint.
    case restrict
    
    /// The `CASCADE` behavior.
    ///
    /// `CASCADE` specifies that the action which triggered the constraint violation shall be forwarded to
    /// the referenced foreign row(s) (causing them to be deleted or updated as appropriate). Cascading foreign
    /// key behaviors are recursive.
    case cascade
    
    /// The `SET NULL` behavior.
    ///
    /// `SET NULL` specifies that a violation of a foreign key constraint shall result in setting the values of
    /// the columns comprising the constraint to `NULL`.
    case setNull
    
    /// The `SET DEFAULT` behavior.
    ///
    /// `SET DEFAULT` specifies that a violation of a foreign key constraint shall result in setting the values of
    /// the columns comprising the constraint to their respective default values. The resulting contents of the
    /// updated row must comprise a valid reference to the foreign table.
    case setDefault
    
    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .noAction: serializer.write("NO ACTION")
        case .restrict: serializer.write("RESTRICT")
        case .cascade: serializer.write("CASCADE")
        case .setNull: serializer.write("SET NULL")
        case .setDefault: serializer.write("SET DEFAULT")
        }
    }
}
