/// A SQL search predicate (a.k.a, filter). Listed after `WHERE` in a SQL statement.
public struct DataPredicate {
    /// The left-hand side of the predicate. References a column being fetched.
    public var column: DataColumn

    /// The method of comparison to use. Usually `=`, `<`, etc.
    public var comparison: DataPredicateComparison

    /// The value to compare to. Can be another column, static value, or more SQL.
    public var value: DataPredicateValue

    /// Creates a SQL `DataPredicate`.
    public init(column: DataColumn, comparison: DataPredicateComparison, value: DataPredicateValue = .none) {
        self.column = column
        self.comparison = comparison
        self.value = value
    }
}
