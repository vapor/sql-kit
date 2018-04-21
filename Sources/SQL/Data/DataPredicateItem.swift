/// Either a single SQL `DataPredicate` or a group (AND/OR) of them.
public enum DataPredicateItem {
    /// A collection of `DataPredicate` items joined by AND or OR.
    case group(DataPredicateGroup)
    /// A single data predicate.
    case predicate(DataPredicate)
}
