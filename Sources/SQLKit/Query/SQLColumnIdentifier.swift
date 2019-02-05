///// Identifies a column in a particular table.
//public protocol SQLColumnIdentifier: SQLSerializable {
//    /// Creates a new `SQLColumnIdentifier`.
//    init(name: SQLIdentifier, table: SQLIdentifier?)
//
//    /// Optional identifier for the table this column belongs to.
//    var table: SQLIdentifier? { get set }
//
//    /// Column identifier.
//    var name: SQLIdentifier { get set }
//}

public struct SQLColumn: SQLExpression {
    public var name: SQLExpression
    public var table: SQLExpression?
    
    public init(_ name: String, table: String? = nil) {
        self.init(SQLIdentifier(name), table: table.flatMap(SQLIdentifier.init))
    }
    
    public init(_ name: SQLExpression, table: SQLExpression? = nil) {
        self.name = name
        self.table = table
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        if let table = self.table {
            table.serialize(to: &serializer)
            serializer.write(".")
        }
        self.name.serialize(to: &serializer)
    }
}

public struct SQLAlias: SQLExpression {
    public var expression: SQLExpression
    public var alias: SQLExpression
    
    public init(_ expression: SQLExpression, as alias: SQLExpression) {
        self.expression = expression
        self.alias = alias
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        self.expression.serialize(to: &serializer)
        serializer.write(" AS ")
        self.alias.serialize(to: &serializer)
    }
}
