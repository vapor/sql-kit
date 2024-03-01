/// Specifies a behavior when performing a `DROP` operation on a database object which is referenced by other objects.
///
/// > Warning: These behaviors are not supported by all dialects.
public enum SQLDropBehavior: SQLExpression {
    /// Refuse to drop the object if it has any remaining references from other objects.
    case restrict
    
    /// When the object is referenced from other objects, recursively delete the referencing objects as well.
    case cascade
    
    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .restrict: serializer.write("RESTRICT")
        case .cascade:  serializer.write("CASCADE")
        }
    }
}
