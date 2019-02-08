/// `SELECT` statement.
///
/// See `SQLSelectBuilder` for building this query.
public struct SQLSelect: SQLExpression {
    public var columns: [SQLExpression]
    public var tables: [SQLExpression]
    
    public var isDistinct: Bool
    
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
    
    public var lockingClause: SQLExpression?
    
    public init() {
        self.columns = []
        self.tables = []
        self.isDistinct = false
        self.joins = []
        self.predicate = nil
        self.limit = nil
        self.offset = nil
        self.groupBy = []
        self.orderBy = []
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write("SELECT ")
        if self.isDistinct {
            serializer.write("DISTINCT ")
        }
        SQLList(self.columns).serialize(to: &serializer)
        serializer.write(" FROM ")
        SQLList(self.tables).serialize(to: &serializer)
        if !self.joins.isEmpty {
            serializer.write(" ")
            SQLList(self.joins).serialize(to: &serializer)
        }
        if let predicate = self.predicate {
            serializer.write(" WHERE ")
            predicate.serialize(to: &serializer)
        }
        if !self.groupBy.isEmpty {
            serializer.write(" GROUP BY ")
            SQLList(self.groupBy).serialize(to: &serializer)
        }
        if !self.orderBy.isEmpty {
            serializer.write(" ORDER BY ")
            SQLList(self.orderBy).serialize(to: &serializer)
        }
        if let limit = self.limit {
            serializer.write(" LIMIT ")
            serializer.write(limit.description)
        }
        if let offset = self.offset {
            serializer.write(" OFFSET ")
            serializer.write(offset.description)
        }
        if let lockingClause = self.lockingClause {
            serializer.write(" ")
            lockingClause.serialize(to: &serializer)
        }
    }
}
