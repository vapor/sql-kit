public protocol SQLUpsert: SQLSerializable {
    associatedtype Identifier: SQLIdentifier
    associatedtype Expression: SQLExpression
    
    static func upsert(_ values: [(Identifier, Expression)]) -> Self
    
    var values: [(Identifier, Expression)] { get set }
}

public struct GenericSQLUpsert<Identifier, Expression>: SQLUpsert
    where Identifier: SQLIdentifier, Expression: SQLExpression
{
    /// See `SQLUpsert`.
    public typealias `Self` = GenericSQLUpsert<Identifier, Expression>
    
    /// See `SQLUpsert`.
    public static func upsert(_ values: [(Identifier, Expression)]) -> GenericSQLUpsert<Identifier, Expression> {
        return self.init(values: values)
    }
    
    /// See `SQLUpsert`.
    public var values: [(Identifier, Expression)]
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append("ON CONFLICT DO UPDATE SET")
        sql.append(values.map { $0.0.serialize(&binds) + " = " + $0.1.serialize(&binds) }.joined(separator: ", "))
        return sql.joined(separator: " ")
    }
}
