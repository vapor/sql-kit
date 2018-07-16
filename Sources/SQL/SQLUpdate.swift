/// `UPDATE` statement.
///
/// See `SQLUpdateBuilder`.
public protocol SQLUpdate: SQLSerializable {
    /// See `SQLTableIdentifier`.
    associatedtype TableIdentifier: SQLTableIdentifier
    
    /// See `SQLIdentifier`.
    associatedtype Identifier: SQLIdentifier
    
    /// See `SQLExpression`.
    associatedtype Expression: SQLExpression
    
    /// Creates a new `SQLUpdate`.
    static func update(_ table: TableIdentifier) -> Self
    
    /// Table to update.
    var table: TableIdentifier { get set }
    
    /// Zero or more identifier: expression pairs to update.
    var values: [(Identifier, Expression)] { get set }
    
    /// Optional predicate to limit updated rows.
    var predicate: Expression? { get set }
}

// MARK: Generic

/// Generic implementation of `SQLUpdate`.
public struct GenericSQLUpdate<TableIdentifier, Identifier, Expression>: SQLUpdate
    where TableIdentifier: SQLTableIdentifier, Identifier: SQLIdentifier, Expression: SQLExpression
{
    /// Convenience typealias for self.
    public typealias `Self` = GenericSQLUpdate<TableIdentifier, Identifier, Expression>
    
    /// Creates a new `SQLUpdate`.
    public static func update(_ table: TableIdentifier) -> Self {
        return .init(table: table, values: [], predicate: nil)
    }
    
    public var table: TableIdentifier
    public var values: [(Identifier, Expression)]
    public var predicate: Expression?
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append("UPDATE")
        sql.append(table.serialize(&binds))
        sql.append("SET")
        sql.append(values.map { $0.0.serialize(&binds) + " = " + $0.1.serialize(&binds) }.joined(separator: ", "))
        if let predicate = self.predicate {
            sql.append("WHERE")
            sql.append(predicate.serialize(&binds))
        }
        return sql.joined(separator: " ")
    }
}
