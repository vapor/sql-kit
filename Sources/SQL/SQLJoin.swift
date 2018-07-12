/// `JOIN` clause.
public protocol SQLJoin: SQLSerializable {
    /// See `SQLJoinMethod`.
    associatedtype Method: SQLJoinMethod
    
    /// See `SQLTableIdentifier`.
    associatedtype TableIdentifier: SQLTableIdentifier
    
    /// See `SQLExpression`.
    associatedtype Expression: SQLExpression
    
    /// Creates a new `SQLJoin`.
    static func join(_ method: Method, _ table: TableIdentifier, _ expression: Expression) -> Self
}

// MARK: Generic

/// Generic implementation of `SQLJoin`.
public struct GenericSQLJoin<Method, TableIdentifier, Expression>: SQLJoin
    where Method: SQLJoinMethod, TableIdentifier: SQLTableIdentifier, Expression: SQLExpression
    
{
    /// See `SQLJoin`.
    public static func join(_ method: Method, _ table: TableIdentifier, _ expression: Expression) -> GenericSQLJoin<Method, TableIdentifier, Expression> {
        return .init(method: method, table: table, expression: expression)
    }
    
    /// See `SQLJoin`.
    public var method: Method
    
    /// See `SQLJoin`.
    public var table: TableIdentifier
    
    /// See `SQLJoin`.
    public var expression: Expression
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        return method.serialize(&binds) + " JOIN " + table.serialize(&binds) + " ON " + expression.serialize(&binds)
    }
}
