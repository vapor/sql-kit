/// `JOIN` clause.
public protocol SQLJoin: SQLSerializable {
    /// See `SQLJoinMethod`.
    associatedtype Method: SQLJoinMethod
    
    /// See `SQLTableIdentifier`.
    associatedtype Identifier: SQLIdentifier
    
    /// See `SQLExpression`.
    associatedtype Expression: SQLExpression
    
    /// Creates a new `SQLJoin`.
    static func join(method: Method, table: Identifier, expression: Expression) -> Self
}
