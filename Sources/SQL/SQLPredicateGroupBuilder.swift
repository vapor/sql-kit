public final class SQLPredicateGroupBuilder<PredicateBuilder>: SQLPredicateBuilder where PredicateBuilder: SQLPredicateBuilder {
    public typealias Expression = PredicateBuilder.Expression
    public var predicate: PredicateBuilder.Expression?
    internal init(_ type: PredicateBuilder.Type) { }
}

extension SQLPredicateBuilder {
    public func `where`(group: (SQLPredicateGroupBuilder<Self>) throws -> ()) rethrows -> Self {
        let builder = SQLPredicateGroupBuilder(Self.self)
        try group(builder)
        if let sub = builder.predicate {
            self.predicate &= sub
        }
        return self
    }
}
