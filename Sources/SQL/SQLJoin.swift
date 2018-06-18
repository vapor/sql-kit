public protocol SQLJoin: SQLSerializable {
    associatedtype Method: SQLJoinMethod
    associatedtype TableIdentifier: SQLTableIdentifier
    associatedtype Expression: SQLExpression
    
    static func join(_ method: Method, _ table: TableIdentifier, _ expression: Expression) -> Self
}

public struct GenericSQLJoin<Method, TableIdentifier, Expression>: SQLJoin
    where Method: SQLJoinMethod, TableIdentifier: SQLTableIdentifier, Expression: SQLExpression
    
{
    /// See `SQLJoin`.
    public static func join(_ method: Method, _ table: TableIdentifier, _ expression: Expression) -> GenericSQLJoin<Method, TableIdentifier, Expression> {
        return .init(method: method, table: table, expression: expression)
    }
    
    public var method: Method
    public var table: TableIdentifier
    public var expression: Expression
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        return method.serialize(&binds) + " JOIN " + table.serialize(&binds) + " ON " + expression.serialize(&binds)
    }
}
