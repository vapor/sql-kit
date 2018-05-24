/// All suported SQL `DataPredicate` comparisons.
public enum DataPredicateComparison: Equatable {
    /// =
    case equal
    /// !=, <>
    case notEqual
    /// <
    case lessThan
    /// >
    case greaterThan
    /// <=
    case lessThanOrEqual
    /// >=
    case greaterThanOrEqual
    /// IN
    case `in`
    /// NOT IN
    case notIn
    /// BETWEEN
    case between
    /// LIKE
    case like
    /// NOT LIKE
    case notLike
    /// Raw SQL string
    case sql(String)
}
