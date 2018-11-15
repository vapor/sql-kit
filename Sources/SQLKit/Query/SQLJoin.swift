/// `JOIN` clause.
public protocol SQLJoin: SQLSerializable {
    /// See `SQLJoinMethod`.
    associatedtype Method: SQLJoinMethod
    
    /// See `SQLTableIdentifier`.
    associatedtype Identifier
    
    /// See `SQLExpression`.
    associatedtype Expression: SQLExpression where
        Expression.Identifier == Identifier,
        Expression.ColumnIdentifier.Identifier == Identifier
    
    /// Creates a new `SQLJoin`.
    static func join(method: Method, table: Identifier, expression: Expression) -> Self
}
