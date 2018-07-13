/// `SELECT` statement.
///
/// See `SQLSelectBuilder` for building this query.
public protocol SQLSelect: SQLSerializable {
    /// See `SQLDistinct`.
    associatedtype Distinct: SQLDistinct
    
    /// See `SQLSelectExpression`.
    associatedtype SelectExpression: SQLSelectExpression
    
    /// See `SQLTableIdentifier`.
    associatedtype TableIdentifier: SQLTableIdentifier
    
    /// See `SQLJoin`.
    associatedtype Join: SQLJoin
    
    /// See `SQLExpression`.
    associatedtype Expression: SQLExpression
    
    /// See `SQLGroupBy`.
    associatedtype GroupBy: SQLGroupBy
    
    /// See `SQLOrderBy`.
    associatedtype OrderBy: SQLOrderBy
    
    /// Creates a new `SQLSelect`.
    static func select() -> Self
    
    /// Distinct modifier.
    var distinct: Distinct? { get set }
    
    /// Select expressions.
    /// These define the columns in the result set.
    var columns: [SelectExpression] { get set }
    
    /// Zero or more tables to select from.
    var tables: [TableIdentifier] { get set }
    
    /// Zero or more tables to join.
    var joins: [Join] { get set }
    
    /// `WHERE` clause.
    var predicate: Expression? { get set }
    
    /// Zero or more `GROUP BY` clauses.
    var groupBy: [GroupBy] { get set }
    
    /// Zero or more `ORDER BY` clauses.
    var orderBy: [OrderBy] { get set }
    
    /// If set, limits the maximum number of results.
    var limit: Int? { get set }
    
    /// If set, offsets the results.
    var offset: Int? { get set }
}

// MARK: Generic

/// Generic implementation of `SQLSelect`.
public struct GenericSQLSelect<Distinct, SelectExpression, TableIdentifier, Join, Expression, GroupBy, OrderBy>: SQLSelect
where Distinct: SQLDistinct,
    SelectExpression: SQLSelectExpression,
    TableIdentifier: SQLTableIdentifier,
    Join: SQLJoin,
    Expression: SQLExpression,
    GroupBy: SQLGroupBy,
    OrderBy: SQLOrderBy
{
    /// Convenience typealias for self.
    public typealias `Self` = GenericSQLSelect<Distinct, SelectExpression, TableIdentifier, Join, Expression, GroupBy, OrderBy>
    
    /// See `SQLSelect`.
    public var distinct: Distinct?
    
    /// See `SQLSelect`.
    public var columns: [SelectExpression]
    
    /// See `SQLSelect`.
    public var tables: [TableIdentifier]
    
    /// See `SQLSelect`.
    public var joins: [Join]
    
    /// See `SQLSelect`.
    public var predicate: Expression?
    
    /// See `SQLSelect`.
    public var groupBy: [GroupBy]
    
    /// See `SQLSelect`.
    public var orderBy: [OrderBy]
    
    /// See `SQLSelect`.
    public var limit: Int?
    
    /// See `SQLSelect`.
    public var offset: Int?
    
    /// See `SQLSelect`.
    public static func select() -> Self {
        return .init(distinct: nil, columns: [], tables: [], joins: [], predicate: nil, groupBy: [], orderBy: [], limit: nil, offset: nil)
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
        if let limit = self.limit {
            sql.append("LIMIT")
            sql.append(limit.description)
        }
        if let offset = self.offset {
            sql.append("OFFSET")
            sql.append(offset.description)
        }
        return sql.joined(separator: " ")
    }
}
