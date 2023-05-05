/// Nested ``SQLSecondaryPredicateBuilder`` for building expression groups.
public final class SQLSecondaryPredicateGroupBuilder: SQLSecondaryPredicateBuilder {
    /// See ``SQLSecondaryPredicateBuilder/secondaryPredicate``.
    public var secondaryPredicate: (any SQLExpression)?
    
    /// Create a new ``SQLSecondaryPredicateGroupBuilder``.
    @usableFromInline
    init() {}
}

extension SQLSecondaryPredicateBuilder {
    /// Builds a grouped `HAVING` expression by conjunction (`AND`).
    ///
    ///     builder.having("type", .equal, .smallRocky).having {
    ///         $0.having("name", .equal, "Earth").orHaving("name", .equal, "Mars")
    ///     }
    ///
    /// The above code would result in the following SQL.
    ///
    ///     HAVING "type" = "smallRocky" AND ("name" = "Earth" OR "name" = "Mars")
    @inlinable
    @discardableResult
    public func having(group: (SQLSecondaryPredicateGroupBuilder) throws -> (SQLSecondaryPredicateGroupBuilder)) rethrows -> Self {
        let builder = SQLSecondaryPredicateGroupBuilder()
        _ = try group(builder)
        if let sub = builder.secondaryPredicate {
            return self.having(SQLGroupExpression(sub))
        } else {
            return self
        }
    }
    
    /// Builds a grouped `HAVING` expression by disjunction ('OR').
    ///
    ///     builder.having("name", .equal, "Jupiter").orHaving {
    ///         $0.having("name", .equal, "Earth").having("type", .equal, PlanetType.smallRocky)
    ///     }
    ///
    /// The above code would result in the following SQL.
    ///
    ///     HAVING "name" = "Jupiter" OR ("name" = "Earth" AND "type" = "smallRocky")
    @inlinable
    @discardableResult
    public func orHaving(group: (SQLSecondaryPredicateGroupBuilder) throws -> (SQLSecondaryPredicateGroupBuilder)) rethrows -> Self {
        let builder = SQLSecondaryPredicateGroupBuilder()
        _ = try group(builder)
        if let sub = builder.secondaryPredicate {
            return self.orHaving(SQLGroupExpression(sub))
        } else {
            return self
        }
    }
}
