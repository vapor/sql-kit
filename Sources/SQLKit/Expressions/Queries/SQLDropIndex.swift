/// An expression representing a `DROP INDEX` query. Used to delete indexes from tables.
///
/// ```sql
/// DROP INDEX IF EXISTS ON `table` CASCADE;
/// ```
///
/// Not all dialects require or allow specifying the owning table of an index when dropping it, while others enforce
/// doing so. There is no dialect functionality enabling a check for this at this time, so users must track for
/// themselves whether or not to specify the table. At the time of this writing, the table _must_ be specified for
/// MySQL and must _not_ be specified for other drivers.
///
/// See ``SQLDropIndexBuilder``.
public struct SQLDropIndex: SQLExpression {
    /// The name of the index to drop.
    public var name: any SQLExpression
    
    /// If `true`, requests idempotent behavior (e.g. that no error be raised if the named index does not exist).
    ///
    /// Ignored if not supported by the dialect.
    public var ifExists: Bool
    
    /// The object (usually a table) on which the index exists.
    ///
    /// Not allowed by most dialects. Required by the MySQL dialect.
    public var owningObject: (any SQLExpression)?

    /// A drop behavior.
    ///
    /// Ignored if not supported by the dialect. See ``SQLDropBehavior``.
    public var behavior: (any SQLExpression)?

    /// Create a new index deletion query.
    ///
    /// - Parameter name: The name of the index to delete.
    @inlinable
    public init(name: any SQLExpression) {
        self.name = name
        self.ifExists = false
    }
    
    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("DROP INDEX")
            if self.ifExists, $0.dialect.supportsIfExists {
                $0.append("IF EXISTS")
            }
            $0.append(self.name)
            if let owningObject = self.owningObject {
                $0.append("ON", owningObject)
            }
            if $0.dialect.supportsDropBehavior {
                $0.append(self.behavior)
            }
        }
    }
}
