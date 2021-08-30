public final class SQLUnionBuilder: SQLQueryBuilder {
    public var query: SQLExpression { self.union }

    public var union: SQLUnion
    public var database: SQLDatabase

    public init(on database: SQLDatabase, initialQuery: SQLSelect) {
        self.union = .init(initialQuery: initialQuery)
        self.database = database
    }

   public func union(distinct query: SQLSelect) -> Self {
       self.union.add(query, all: false)
       return self
   }

   public func union(all query: SQLSelect) -> Self {
       self.union.add(query, all: true)
       return self
   }
}

extension SQLDatabase {
    public func union(_ predicate: (SQLSelectBuilder) -> SQLSelectBuilder) -> SQLUnionBuilder {
        return SQLUnionBuilder(on: self, initialQuery: predicate(.init(on: self)).select)
    }
}

extension SQLUnionBuilder {
    public func union(distinct predicate: (SQLSelectBuilder) -> SQLSelectBuilder) -> Self {
        return self.union(distinct: predicate(.init(on: self.database)).select)
    }

    /// Alias the `distinct` variant so it acts as the "default".
    public func union(_ predicate: (SQLSelectBuilder) -> SQLSelectBuilder) -> Self {
        return self.union(distinct: predicate)
    }

    public func union(all predicate: (SQLSelectBuilder) -> SQLSelectBuilder) -> Self {
        return self.union(all: predicate(.init(on: self.database)).select)
    }
}
