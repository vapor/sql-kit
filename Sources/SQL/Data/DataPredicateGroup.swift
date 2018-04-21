/// A group of SQL `DataPredicate`s joined by a relation (`AND`, `OR`, etc).
public struct DataPredicateGroup {
    /// The relation these predicates are joined by, usually `AND`.
    public var relation: DataPredicateGroupRelation

    /// One or more sub-predicates.
    public var predicates: [DataPredicateItem]

    /// Creates a new `DataPredicateGroup`
    public init(relation: DataPredicateGroupRelation, predicates: [DataPredicateItem]) {
        self.relation = relation
        self.predicates = predicates
    }
}

/// Supported data predicate relations.
public enum DataPredicateGroupRelation {
    /// AND
    case and
    /// OR
    case or
    /// custom
    case custom(String)
}
