/// SQL data manipulation query (DML)
public struct DataManipulationQuery {
    /// The statement type: `INSERT`, `UPDATE`, `DELETE`.
    public var statement: DataManipulationStatement

    /// The table to query.
    public var table: String

    /// List of columns to manipulate.
    public var columns: [DataManipulationColumn]

    /// List of joins to execute.
    public var joins: [DataJoin]

    /// List of predicates to filter by.
    public var predicates: [DataPredicateItem]

    /// Optional query limit. If set, result count must be less than the limit provided.
    public var limit: Int?

    /// Creates a new `DataManipulationQuery`
    public init(
        statement: DataManipulationStatement,
        table: String,
        columns: [DataManipulationColumn] = [],
        joins: [DataJoin] = [],
        predicates: [DataPredicateItem] = [],
        limit: Int? = nil
    ) {
        self.statement = statement
        self.table = table
        self.columns = columns
        self.joins = joins
        self.predicates = predicates
        self.limit = limit
    }
}
