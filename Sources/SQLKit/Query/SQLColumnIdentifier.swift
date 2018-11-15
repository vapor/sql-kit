/// Identifies a column in a particular table.
public protocol SQLColumnIdentifier: SQLSerializable, ExpressibleByStringLiteral {
    /// See `SQLIdentifier`.
    associatedtype Identifier: SQLIdentifier
    
    /// Creates a new `SQLColumnIdentifier`.
    static func column(name: Identifier, table: Identifier?) -> Self
    
    /// Optional identifier for the table this column belongs to.
    var table: Identifier? { get set }
    
    /// Column identifier.
    var name: Identifier { get set }
}
