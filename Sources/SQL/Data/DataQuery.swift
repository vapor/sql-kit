/// SQL data manipulation query (DML)
public struct DataQuery {
    /// The statement type, SELECT, INSERT, etc.
    public var statement: DataStatement

    /// The table to query.
    public var table: String

    /// List of columns to fetch.
    public var columns: [DataColumn]

    /// List of computed columns to fetch.
    public var computed: [DataComputed]

    /// List of joins to execute.
    public var joins: [DataJoin]

    /// List of predicates to filter by.
    public var predicates: [DataPredicateItem]

    /// List of columns to order by.
    public var orderBys: [DataOrderBy]

    /// GROUP BY YEAR(date)
    public var groupBys: [DataGroupBy]

    /// Optional query limit. If set, result count must be less than the limit provided.
    public var limit: Int?

    /// Optional query offset. If set, results will be offset by the number provided.
    public var offset: Int?

    /// If set, and `true`, only unique rows with unique values
    /// should be returned by this query.
    public var distinct: Bool?

    /// Creates a new `DataQuery`
    public init(
        statement: DataStatement,
        table: String,
        columns: [DataColumn] = [],
        computed: [DataComputed] = [],
        joins: [DataJoin] = [],
        predicates: [DataPredicateItem] = [],
        orderBys: [DataOrderBy] = [],
        groupBy: [DataGroupBy] = [],
        limit: Int? = nil,
        offset: Int? = nil,
        distinct: Bool? = nil
    ) {
        self.statement = statement
        self.table = table
        self.columns = columns
        self.computed = computed
        self.joins = joins
        self.predicates = predicates
        self.orderBys = orderBys
        self.groupBys = groupBy
        self.limit = limit
        self.offset = offset
    }
}
