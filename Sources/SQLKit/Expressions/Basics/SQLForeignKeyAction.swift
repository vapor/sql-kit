/// `RESTRICT | CASCADE | SET NULL | NO ACTION | SET DEFAULT`
public enum SQLForeignKeyAction: SQLExpression {
    /// Produce an error indicating that the deletion or update would create a foreign key constraint violation.
    /// If the constraint is deferred, this error will be produced at constraint check time if there still exist any referencing rows.
    /// This is the default action.
    case noAction
    
    /// Produce an error indicating that the deletion or update would create a foreign key constraint violation.
    case restrict
    
    /// Delete any rows referencing the deleted row, or update the values of the referencing column(s) to the new values of the referenced columns, respectively.
    case cascade
    
    /// Set the referencing column(s) to null.
    case setNull
    
    /// Set the referencing column(s) to their default values.
    /// (There must be a row in the referenced table matching the default values, if they are not null, or the operation will fail.)
    case setDefault
    
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
