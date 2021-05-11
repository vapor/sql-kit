/// Nested `SQLPredicateBuilder` for building expression groups.
///
///     builder.where(\Planet.type == .smallRocky).where {
///         $0.where(\Planet.name == "Earth").orWhere(\Planet.name == "Mars")
///     }
///
public final class SQLPredicateGroupBuilder: SQLPredicateBuilder {
    /// See `SQLPredicateBuilder`.
    public var predicate: SQLExpression?
    
    /// Creates a new `SQLPredicateGroupBuilder`.
    internal init() { }
}

extension SQLPredicateBuilder {
    /// Builds a grouped `WHERE` expression.
    ///
    ///     builder.where(\Planet.type == .smallRocky).where {
    ///         $0.where(\Planet.name == "Earth").orWhere(\Planet.name == "Mars")
    ///     }
    ///
    /// The above code would result in the following SQL.
    ///
    ///     WHERE "type" = "smallRocky" AND ("name" = "Earth" OR "name" = "Mars")
    ///
    @discardableResult
    public func `where`(group: (SQLPredicateGroupBuilder) -> (SQLPredicateGroupBuilder)) -> Self {
        let builder = SQLPredicateGroupBuilder()
        _ = group(builder)
        if let sub = builder.predicate {
            return self.where(SQLGroupExpression(sub))
        } else {
            return self
        }
    }
    
    /// Builds a grouped `WHERE` expression.
    ///
    ///     builder.where(\Planet.name == "Jupiter").orWhere {
    ///         $0.where(\Planet.name == "Earth").where(\Planet.type == .smallRocky)
    ///     }
    ///
    /// The above code would result in the following SQL.
    ///
    ///     WHERE "name" = "Jupiter" OR ("name" = "Earth" AND "type" = "smallRocky")
    ///
    @discardableResult
    public func orWhere(group: (SQLPredicateGroupBuilder) -> (SQLPredicateGroupBuilder)) -> Self {
        let builder = SQLPredicateGroupBuilder()
        _ = group(builder)
        if let sub = builder.predicate {
            return self.orWhere(SQLGroupExpression(sub))
        } else {
            return self
        }
    }
}
