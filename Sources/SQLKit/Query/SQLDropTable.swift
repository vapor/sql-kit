/// `DROP TABLE` query.
///
/// See `SQLDropTableBuilder`.
public struct SQLDropTable: SQLExpression {
    /// Table to drop.
    public let table: SQLExpression
    
    /// The optional `IF EXISTS` clause suppresses the error that would normally
    /// result if the table does not exist.
    public var ifExists: Bool

    /// The optional drop behaviour clause specifies if objects that depend on the
    /// table should also be dropped or not, for databases that supports this
    /// (either `CASCADE` or `RESTRICT`).
    public var behaviour: SQLExpression?

    /// Creates a new `SQLDropTable`.
    public init(table: SQLExpression) {
        self.table = table
        self.ifExists = false
    }
    
    /// See `SQLExpression`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write("DROP TABLE ")
        if self.ifExists {
            if serializer.dialect.supportsIfExists {
                serializer.write("IF EXISTS ")
            } else {
                serializer.database.logger.warning("\(serializer.dialect.name) does not support IF EXISTS")
            }
        }
        self.table.serialize(to: &serializer)
        if serializer.dialect.supportsDropBehaviour {
            serializer.write(" ")
            if let dropBehaviour = behaviour {
                dropBehaviour.serialize(to: &serializer)
            } else {
                SQLDropBehaviour.cascade.serialize(to: &serializer)
            }
        }
    }
}
