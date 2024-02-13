/// An expression representing an optionally table-qualified column in an SQL table.
public struct SQLColumn: SQLExpression {
    /// The column name, usually an ``SQLIdentifier``.
    public var name: any SQLExpression
    
    /// If specified, the table to which the column belongs. Usually an ``SQLIdentifier`` when not `nil`.
    public var table: (any SQLExpression)?
    
    /// Create an ``SQLColumn`` from a name and optional table name.
    @inlinable
    public init(_ name: String, table: String? = nil) {
        self.init(SQLIdentifier(name), table: table.flatMap(SQLIdentifier.init(_:)))
    }
    
    /// Create an ``SQLColumn`` from an identifier and optional table identifier.
    @inlinable
    public init(_ name: any SQLExpression, table: (any SQLExpression)? = nil) {
        self.name = name
        self.table = table
    }
    
    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            if let table = self.table {
                $0.append(table, ".")
            }
            $0.append(self.name)
        }
    }
}
