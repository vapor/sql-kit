/// An expression representing an optionally table-qualified column in an SQL table.
public struct SQLColumn: SQLExpression {
    /// The column name.
    ///
    /// Usually an ``SQLIdentifier``.
    public var name: any SQLExpression
    
    /// If specified, the table to which the column belongs.
    ///
    /// Usually an ``SQLIdentifier`` or ``SQLQualifiedTable`` when not `nil`.
    public var table: (any SQLExpression)?
    
    /// Create an ``SQLColumn`` from a name and optional table name.
    ///
    /// A column name of `*` is treated as ``SQLLiteral/all`` rather than as an identifier. To specify a column whose
    /// actual name consists of a sole asterisk (probably not a good idea to have one of those in the first place),
    /// use ``init(_:table:)-77d24`` and `SQLIdentifier("*")`.
    @inlinable
    public init(_ name: String, table: String? = nil) {
        self.init(name == "*" ? SQLLiteral.all : SQLIdentifier(name), table: table.flatMap(SQLIdentifier.init(_:)))
    }
    
    /// Create an ``SQLColumn`` from an identifier and optional table expression.
    @inlinable
    public init(_ name: any SQLExpression, table: (any SQLExpression)? = nil) {
        self.name = name
        self.table = table
    }
    
    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        if let table = self.table {
            table.serialize(to: &serializer)
            serializer.write(".")
        }
        self.name.serialize(to: &serializer)
    }
}
