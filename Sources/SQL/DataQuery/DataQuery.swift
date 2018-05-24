///// SQL data query language (DQL).
//public struct DataQuery {
//    /// The table to query.
//    public var table: String
//
//    /// List of columns to fetch.
//    public var columns: [DataQueryColumn]
//
//    /// List of joins to execute.
//    public var joins: [DataJoin]
//
//    /// List of predicates to filter by.
//    public var predicates: [DataPredicateItem]
//
//    /// List of columns to order by.
//    public var orderBys: [DataOrderBy]
//
//    /// `GROUP BY YEAR(date)`.
//    public var groupBys: [DataGroupBy]
//
//    /// Optional query limit. If set, result count must be less than the limit provided.
//    public var limit: Int?
//
//    /// Optional query offset. If set, results will be offset by the number provided.
//    public var offset: Int?
//
//    /// If `true`, only unique rows with unique values should be returned by this query.
//    public var distinct: Bool
//
//    /// Creates a new `DataQuery`.
//    public init(
//        table: String,
//        columns: [DataQueryColumn] = [.all],
//        joins: [DataJoin] = [],
//        predicates: [DataPredicateItem] = [],
//        orderBys: [DataOrderBy] = [],
//        groupBys: [DataGroupBy] = [],
//        limit: Int? = nil,
//        offset: Int? = nil,
//        distinct: Bool = false
//    ) {
//        self.table = table
//        self.columns = columns
//        self.joins = joins
//        self.predicates = predicates
//        self.orderBys = orderBys
//        self.groupBys = groupBys
//        self.limit = limit
//        self.offset = offset
//        self.distinct = false
//    }
//}
