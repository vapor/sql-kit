/// Nested `SQLPredicateBuilder` for building expression groups.
///
///     builder.where(\Planet.type == .smallRocky).where {
///         $0.where(\Planet.name == "Earth").orWhere(\Planet.name == "Mars")
///     }
///
public final class SQLPredicateGroupBuilder<PredicateBuilder>: SQLPredicateBuilder
    where PredicateBuilder: SQLPredicateBuilder
{
    /// See `SQLPredicateBuilder`.
    public typealias Expression = PredicateBuilder.Expression
    
    /// See `SQLPredicateBuilder`.
    public var predicate: PredicateBuilder.Expression?
    
    /// Creates a new `SQLPredicateGroupBuilder`.
    internal init(_ type: PredicateBuilder.Type) { }
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
    public func `where`(group: (SQLPredicateGroupBuilder<Self>) -> (SQLPredicateGroupBuilder<Self>)) -> Self {
        let builder = SQLPredicateGroupBuilder(Self.self)
        _ = group(builder)
        if let sub = builder.predicate {
            return self.where(.group(sub))
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
    public func orWhere(group: (SQLPredicateGroupBuilder<Self>) -> (SQLPredicateGroupBuilder<Self>)) -> Self {
        let builder = SQLPredicateGroupBuilder(Self.self)
        _ = group(builder)
        if let sub = builder.predicate {
            return self.orWhere(.group(sub))
        } else {
            return self
        }
    }
}
