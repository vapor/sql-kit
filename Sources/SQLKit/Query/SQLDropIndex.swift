/// `DROP INDEX` query.
///
/// See `SQLDropIndexBuilder`.
public struct SQLDropIndex: SQLExpression {
    /// Index to drop.
    public var name: SQLExpression
    
    /// The optional `IF EXISTS` clause suppresses the error that would normally
    /// result if the index does not exist.
    public var ifExists: Bool

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
        serializer.write("DROP INDEX ")
        if self.ifExists {
            if serializer.dialect.supportsIfExists {
                serializer.write("IF EXISTS ")
            } else {
                serializer.database.logger.warning("\(serializer.dialect.name) does not support IF EXISTS")
            }
        }
        self.name.serialize(to: &serializer)
        if serializer.dialect.supportsDropBehavior {
            serializer.write(" ")
            if let dropBehavior = behavior {
                dropBehavior.serialize(to: &serializer)
            } else {
                SQLDropBehavior.restrict.serialize(to: &serializer)
            }
        }
    }
}
