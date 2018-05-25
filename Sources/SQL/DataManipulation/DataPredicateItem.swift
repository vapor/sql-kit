/// Either a single SQL `DataPredicate` or a group (AND/OR) of them.
public enum DataPredicates {
    /// A collection of `DataPredicate` items joined by AND or OR.
    case group(DataPredicateGroup)
    
    /// A single `DataPredicate`.
    case predicate(DataPredicate)
}
