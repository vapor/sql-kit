/// `SELECT` statement.
///
/// See `SQLSelectBuilder` for building this query.
//public protocol SQLSelect: SQLQuery {
//    /// See `SQLDistinct`.
//    associatedtype Distinct: SQLDistinct
//
//    /// See `SQLTableIdentifier`.
//    associatedtype Identifier: SQLIdentifier
//
//    /// See `SQLJoin`.
//    associatedtype Join: SQLJoin
//
//    /// See `SQLExpression`.
//    associatedtype Expression: SQLExpression
//
//    /// See `SQLGroupBy`.
//    associatedtype GroupBy: SQLGroupBy
//
//    /// See `SQLOrderBy`.
//    associatedtype OrderBy: SQLOrderBy
//
//    /// Creates a new `SQLSelect`.
//    static func select() -> Self
//
//    /// Distinct modifier.
//    var distinct: Distinct? { get set }
//
//    /// Select expressions.
//    /// These define the columns in the result set.
//    var columns: [Expression] { get set }
//
//    /// Zero or more tables to select from.
//    var tables: [Identifier] { get set }
//
//    /// Zero or more tables to join.
//    var joins: [Join] { get set }
//
//    /// `WHERE` clause.
//    var predicate: Expression? { get set }
//

//}

public struct SQLSelect: SQLExpression {
    public var columns: [SQLExpression]
    public var tables: [SQLExpression]
    
    public var joins: [SQLExpression]
    
    public var predicate: SQLExpression?
    
    /// Zero or more `GROUP BY` clauses.
    public var groupBy: [SQLExpression]
    
    /// Zero or more `ORDER BY` clauses.
    public var orderBy: [SQLExpression]
    
    /// If set, limits the maximum number of results.
    public var limit: Int?
    
    /// If set, offsets the results.
    public var offset: Int?

    
    public init() {
        self.columns = []
        self.tables = []
        self.joins = []
        self.predicate = nil
        self.limit = nil
        self.offset = nil
        self.groupBy = []
        self.orderBy = []
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write("SELECT ")
        self.columns.serialize(to: &serializer, joinedBy: ", ")
        serializer.write(" FROM ")
        self.tables.serialize(to: &serializer, joinedBy: ", ")
        if !self.joins.isEmpty {
            serializer.write(" ")
            self.joins.serialize(to: &serializer, joinedBy: ", ")
        }
        if let predicate = self.predicate {
            serializer.write(" WHERE ")
            predicate.serialize(to: &serializer)
        }
        if !self.groupBy.isEmpty {
            serializer.write(" GROUP BY ")
            self.groupBy.serialize(to: &serializer, joinedBy: ", ")
        }
        if !self.orderBy.isEmpty {
            serializer.write(" ORDER BY ")
            self.orderBy.serialize(to: &serializer, joinedBy: ", ")
        }
        if let limit = self.limit {
            serializer.write(" LIMIT ")
            serializer.write(limit.description)
        }
        if let offset = self.offset {
            serializer.write(" OFFSET ")
            serializer.write(offset.description)
        }
    }
}
