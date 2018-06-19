public protocol SQLSelect: SQLSerializable {
    associatedtype Distinct: SQLDistinct
    associatedtype SelectExpression: SQLSelectExpression
    associatedtype TableIdentifier: SQLTableIdentifier
    associatedtype Join: SQLJoin
    associatedtype Expression: SQLExpression
    associatedtype GroupBy: SQLGroupBy
    associatedtype OrderBy: SQLOrderBy
    
    static func select() -> Self
    
    var distinct: Distinct? { get set }
    var columns: [SelectExpression] { get set }
    var tables: [TableIdentifier] { get set }
    var joins: [Join] { get set }
    var predicate: Expression? { get set }
    var groupBy: [GroupBy] { get set }
    var orderBy: [OrderBy] { get set }
}

// MARK: Generic

public struct GenericSQLSelect<Distinct, SelectExpression, TableIdentifier, Join, Expression, GroupBy, OrderBy>: SQLSelect
where Distinct: SQLDistinct, SelectExpression: SQLSelectExpression, TableIdentifier: SQLTableIdentifier, Join: SQLJoin, Expression: SQLExpression, GroupBy: SQLGroupBy, OrderBy: SQLOrderBy
{
    public typealias `Self` = GenericSQLSelect<Distinct, SelectExpression, TableIdentifier, Join, Expression, GroupBy, OrderBy>
    
    public var distinct: Distinct?
    public var columns: [SelectExpression]
    public var tables: [TableIdentifier]
    public var joins: [Join]
    public var predicate: Expression?
    public var groupBy: [GroupBy]
    public var orderBy: [OrderBy]
    
    /// See `SQLSelect`.
    public static func select() -> Self {
        return .init(distinct: nil, columns: [], tables: [], joins: [], predicate: nil, groupBy: [], orderBy: [])
    }
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append("SELECT")
        if let distinct = self.distinct {
            sql.append(distinct.serialize(&binds))
        }
        sql.append(columns.serialize(&binds))
        if !tables.isEmpty {
            sql.append("FROM")
            sql.append(tables.serialize(&binds))
        }
        if !joins.isEmpty {
            sql.append(joins.serialize(&binds, joinedBy: " "))
        }
        if let predicate = self.predicate {
            sql.append("WHERE")
            sql.append(predicate.serialize(&binds))
        }
        if !groupBy.isEmpty {
            sql.append("GROUP BY")
            sql.append(groupBy.serialize(&binds))
        }
        if !orderBy.isEmpty {
            sql.append("ORDER BY")
            sql.append(orderBy.serialize(&binds))
        }
        return sql.joined(separator: " ")
    }
}
