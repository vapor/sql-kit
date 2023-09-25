/// Nested ``SQLPredicateBuilder`` for building expression groups.
public final class SQLPredicateGroupBuilder: SQLPredicateBuilder {
    /// See ``SQLPredicateBuilder/predicate``.
    public var predicate: (any SQLExpression)?
    
    /// Create a new ``SQLPredicateGroupBuilder``.
    @usableFromInline
    init() {}
}

extension SQLPredicateBuilder {
    /// Builds a grouped `WHERE` expression by conjunction (`AND`).
    ///
    ///     builder.where("type", .equal, PlanetType.smallRocky).where {
    ///         $0.where("name", .equal, "Earth").orWhere("name", .equal, "Mars")
    ///     }
    ///
    /// The above code would result in the following SQL.
    ///
    ///     WHERE "type" = "smallRocky" AND ("name" = "Earth" OR "name" = "Mars")
    @inlinable
    @discardableResult
    public func `where`(group: (SQLPredicateGroupBuilder) throws -> (SQLPredicateGroupBuilder)) rethrows -> Self {
        let builder = SQLPredicateGroupBuilder()
        _ = try group(builder)
        if let sub = builder.predicate {
            return self.where(SQLGroupExpression(sub))
        } else {
            return self
        }
    }
    
    /// Builds a grouped `WHERE` expression by disjunction (`OR`).
    ///
    ///     builder.where("name", .equal, "Jupiter").orWhere {
    ///         $0.where("name", .equal, "Earth").where("type", .equal, PlanetType.smallRocky)
    ///     }
    ///
    /// The above code would result in the following SQL.
    ///
    ///     WHERE "name" = "Jupiter" OR ("name" = "Earth" AND "type" = "smallRocky")
    @inlinable
    @discardableResult
    public func orWhere(group: (SQLPredicateGroupBuilder) throws -> (SQLPredicateGroupBuilder)) rethrows -> Self {
        let builder = SQLPredicateGroupBuilder()
        _ = try group(builder)
        if let sub = builder.predicate {
            return self.orWhere(SQLGroupExpression(sub))
        } else {
            return self
        }
    }
}
