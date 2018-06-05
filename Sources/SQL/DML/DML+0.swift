extension SQLQuery {
    /// SQL data manipulation query (DML)
    public struct DML {
        /// The statement type: `INSERT`, `UPDATE`, `DELETE`.
        public var statement: Statement

        /// The table to query.
        public var table: String

        /// List of keys to fetch.
        public var keys: [Key]

        /// List of columns to manipulate.
        public var columns: [Column: Value]

        /// List of joins to execute.
        public var joins: [Join]

        /// List of predicates to filter by.
        public var predicates: [Predicate]
        
        /// `GROUP BY YEAR(date)`.
        public var groupBys: [GroupBy]

        /// List of columns to order by.
        public var orderBys: [OrderBy]

        /// Optional query limit. If set, result count must be less than the limit provided.
        public var limit: Int?

        /// Optional query offset. If set, results will be offset by the number provided.
        public var offset: Int?

        /// Creates a new `DML`
        public init(statement: Statement, table: String, keys: [Key] = [], columns: [Column: Value] = [:], joins: [Join] = [], predicates: [Predicate] = [], groupBys: [GroupBy] = [], orderBys: [OrderBy] = [], limit: Int? = nil, offset: Int? = nil) {
            self.statement = statement
            self.table = table
            self.keys = keys
            self.columns = columns
            self.joins = joins
            self.predicates = predicates
            self.orderBys = orderBys
            self.groupBys = groupBys
            self.limit = limit
            self.offset = offset
        }
    }
}
