/// An expression representing an optionally second-level-qualified SQL table.
///
/// The meaning of a second-level qualification as applied to a table is dependent on the underlying database.
/// In PostgreSQL, a table reference is typically qualified with a schema; in MySQL or SQLite, a qualified table
/// reference refers to an alternate database.
public struct SQLQualifiedTable: SQLExpression {
    /// The table name, usually an ``SQLIdentifier``.
    public var table: any SQLExpression
    
    /// If specified, the second-level namespace to which the table belongs.
    /// Usually an ``SQLIdentifier`` if not `nil`.
    public var space: (any SQLExpression)?
    
    /// Create an ``SQLQualifiedTable`` from a name and optional second-level namespace.
    public init(_ table: String, space: String? = nil) {
        self.init(SQLIdentifier(table), space: space.flatMap(SQLIdentifier.init(_:)))
    }
    
    /// Create an ``SQLQualifiedTable`` from an identifier and optional second-level identifier.
    public init(_ table: any SQLExpression, space: (any SQLExpression)? = nil) {
        self.table = table
        self.space = space
    }
    
    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        if let space = self.space {
            space.serialize(to: &serializer)
            serializer.write(".")
        }
        self.table.serialize(to: &serializer)
    }
}
