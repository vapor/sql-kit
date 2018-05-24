/// SQL data manipulation query (DML)
public struct DataManipulationQuery {
    /// The statement type: `INSERT`, `UPDATE`, `DELETE`.
    public var statement: DataManipulationStatement

    /// The table to query.
    public var table: String

    /// List of keys to fetch.
    public var keys: [DataManipulationKey]

    /// List of columns to manipulate.
    public var columns: [DataManipulationColumn]

    /// List of joins to execute.
    public var joins: [DataJoin]

    /// List of predicates to filter by.
    public var predicates: [DataPredicateItem]

    /// List of columns to order by.
    public var orderBys: [DataOrderBy]

    /// `GROUP BY YEAR(date)`.
    public var groupBys: [DataGroupBy]

    /// Optional query limit. If set, result count must be less than the limit provided.
    public var limit: Int?

    /// Optional query offset. If set, results will be offset by the number provided.
    public var offset: Int?

    /// Creates a new `DataManipulationQuery`
    public init(
        statement: DataManipulationStatement,
        table: String,
        keys: [DataManipulationKey] = [.all],
        columns: [DataManipulationColumn] = [],
        joins: [DataJoin] = [],
        predicates: [DataPredicateItem] = [],
        orderBys: [DataOrderBy] = [],
        groupBys: [DataGroupBy] = [],
        limit: Int? = nil,
        offset: Int? = nil
    ) {
        self.statement = statement
        self.table = table
        self.keys = []
        self.columns = columns
        self.joins = joins
        self.predicates = predicates
        self.orderBys = orderBys
        self.groupBys = groupBys
        self.limit = limit
        self.offset = offset
    }
}
