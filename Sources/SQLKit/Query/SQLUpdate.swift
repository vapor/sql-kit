/// `UPDATE` statement.
///
/// See `SQLUpdateBuilder`.
public protocol SQLUpdate: SQLSerializable {
    /// See `SQLIdentifier`.
    associatedtype Identifier: SQLIdentifier
    
    /// See `SQLExpression`.
    associatedtype Expression: SQLExpression
    
    /// Creates a new `SQLUpdate`.
    static func update(table: Identifier) -> Self
    
    /// Table to update.
    var table: Identifier { get set }
    
    /// Zero or more identifier: expression pairs to update.
    var values: [(Identifier, Expression)] { get set }
    
    /// Optional predicate to limit updated rows.
    var predicate: Expression? { get set }
}
