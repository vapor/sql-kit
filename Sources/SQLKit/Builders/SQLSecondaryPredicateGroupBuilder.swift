/// Nested `SQLSecondaryPredicateBuilder` for building expression groups.
///
/// ```swift
/// builder.having("type", .equal, .smallRocky).having {
///     $0.having("name", .equal, "Earth")
///       .orHaving("name", .equal, "Mars")
/// }
/// ```
public final class SQLSecondaryPredicateGroupBuilder: SQLSecondaryPredicateBuilder {
    // See `SQLSecondaryPredicateBuilder.secondaryPredicate`.
    public var secondaryPredicate: SQLExpression?
    
    /// Creates a new `SQLSecondaryPredicateGroupBuilder`.
    internal init() { }
}

extension SQLSecondaryPredicateBuilder {
    /// Builds a grouped `HAVING` expression by conjunction ('AND').
    ///
    /// The following expression:
    ///
    /// ```swift
    /// builder.having("type", .equal, .smallRocky).having {
    ///     $0.having("name", .equal, "Earth")
    ///       .orHaving("name", .equal, "Mars")
    /// }
    /// ```
    ///
    /// ... will result in SQL similar to:
    ///
    /// ```sql
    /// HAVING "type" = 'smallRocky' AND
    ///     ("name" = 'Earth' OR "name" = 'Mars')
    /// ```
    @discardableResult
    public func having(group: (SQLSecondaryPredicateGroupBuilder) -> (SQLSecondaryPredicateGroupBuilder)) -> Self {
        let builder = SQLSecondaryPredicateGroupBuilder()
        _ = group(builder)
        if let sub = builder.secondaryPredicate {
            return self.having(SQLGroupExpression(sub))
        } else {
            return self
        }
    }
    
    /// Builds a grouped `HAVING` expression by disjunction ('OR').
    ///
    /// The following expression:
    ///
    /// ```swift
    /// builder.having("name", .equal, "Jupiter").orHaving {
    ///     $0.having("name", .equal, "Earth")
    ///       .having("type", .equal, .smallRocky)
    /// }
    /// ```
    ///
    /// ... will result in SQL similar to:
    ///
    /// ```sql
    /// HAVING "name" = 'Jupiter' OR
    ///     ("name" = 'Earth' AND "type" = 'smallRocky')
    /// ```
    @discardableResult
    public func orHaving(group: (SQLSecondaryPredicateGroupBuilder) -> (SQLSecondaryPredicateGroupBuilder)) -> Self {
        let builder = SQLSecondaryPredicateGroupBuilder()
        _ = group(builder)
        if let sub = builder.secondaryPredicate {
            return self.orHaving(SQLGroupExpression(sub))
        } else {
            return self
        }
    }
}
