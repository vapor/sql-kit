/// RESTRICT | CASCADE | SET NULL | NO ACTION | SET DEFAULT
public protocol SQLForeignKeyAction: SQLSerializable {
    /// Produce an error indicating that the deletion or update would create a foreign key constraint violation.
    /// If the constraint is deferred, this error will be produced at constraint check time if there still exist any referencing rows.
    /// This is the default action.
    static var noAction: Self { get }
    
    /// Produce an error indicating that the deletion or update would create a foreign key constraint violation.
    static var restrict: Self { get }
    
    /// Delete any rows referencing the deleted row, or update the values of the referencing column(s) to the new values of the referenced columns, respectively.
    static var cascade: Self { get }
    
    /// Set the referencing column(s) to null.
    static var setNull: Self { get }
    
    /// Set the referencing column(s) to their default values.
    /// (There must be a row in the referenced table matching the default values, if they are not null, or the operation will fail.)
    static var setDefault: Self { get }
}
