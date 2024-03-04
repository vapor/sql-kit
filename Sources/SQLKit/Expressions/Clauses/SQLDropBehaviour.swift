/// Specifies a behavior when performing a `DROP` operation on a database object which is referenced by other objects.
///
/// These behaviors are not supported by all dialects. If the dialect does not claim support, nothing is serialized.
public enum SQLDropBehavior: SQLExpression {
    /// Refuse to drop the object if it has any remaining references from other objects.
    case restrict
    
    /// When the object is referenced from other objects, recursively delete the referencing objects as well.
    ///
    /// Be cautious when using ``cascade`` behavior - any object which blocks the drop in any way will be itself
    /// dropped; the cascade recurses as many levels deep as necessary to succeed. This can in some cases result in
    /// unexpected data loss if the dependencies between database objects are poorly understood.
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
