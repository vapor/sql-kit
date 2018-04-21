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
    /// IS NULL
    case isNull
    /// IS NOT NULL
    case isNotNull
    /// No comparison type
    case none
    /// Raw SQL string
    case sql(String)
}
