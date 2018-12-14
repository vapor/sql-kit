/// `SELECT` statement.
///
/// See `SQLSelectBuilder` for building this query.
public protocol SQLSelect: SQLSerializable {
    /// See `SQLDistinct`.
    associatedtype Distinct: SQLDistinct
    
    /// See `SQLTableIdentifier`.
    associatedtype Identifier: SQLIdentifier
    
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
    var columns: [Expression] { get set }
    
    /// Zero or more tables to select from.
    var tables: [Identifier] { get set }
    
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
