/// `DROP INDEX` query.
///
/// See ``SQLDropIndexBuilder``.
public struct SQLDropIndex: SQLExpression {
    /// Index to drop.
    public var name: any SQLExpression
    
    /// The optional `IF EXISTS` clause suppresses the error that would normally
    /// result if the index does not exist.
    public var ifExists: Bool
    
    /// The object (usually a table) on which the index exists. Not all databases support specifying
    /// this, while others require it.
    public var owningObject: (any SQLExpression)?

    /// The optional drop behavior clause specifies if objects that depend on the
    /// index should also be dropped or not, for databases that support this
    /// (either `CASCADE` or `RESTRICT`).
    public var behavior: (any SQLExpression)?

    /// Creates a new `SQLDropIndex`.
    @inlinable
    public init(name: any SQLExpression) {
        self.name = name
        self.ifExists = false
    }
    
    /// See `SQLExpression`.
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
                $0.append(self.behavior ?? SQLDropBehavior.restrict)
            }
        }
    }
}
