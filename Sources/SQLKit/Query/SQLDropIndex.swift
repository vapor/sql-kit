/// `DROP INDEX` query.
///
/// See `SQLDropIndexBuilder`.
public struct SQLDropIndex: SQLExpression {
    /// Index to drop.
    public var name: SQLExpression
    
    /// The optional `IF EXISTS` clause suppresses the error that would normally
    /// result if the index does not exist.
    public var ifExists: Bool
    
    /// The object (usually a table) on which the index exists. Not all databases support specifying
    /// this, while others require it.
    public var owningObject: SQLExpression?

    /// The optional drop behavior clause specifies if objects that depend on the
    /// index should also be dropped or not, for databases that support this
    /// (either `CASCADE` or `RESTRICT`).
    public var behavior: SQLExpression?

    /// Creates a new `SQLDropIndex`.
    public init(name: SQLExpression) {
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
                $0.append("ON")
                $0.append(owningObject)
            }
            if $0.dialect.supportsDropBehavior {
                $0.append(self.behavior ?? SQLDropBehavior.restrict)
            }
        }
    }
}
