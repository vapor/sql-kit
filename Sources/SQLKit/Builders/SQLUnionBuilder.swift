public final class SQLUnionBuilder: SQLQueryBuilder {
    public var query: SQLExpression {
        return self.union
    }

    public var union: SQLUnion
    public var database: SQLDatabase

    public init(on database: SQLDatabase,
                all: Bool = false,
                _ args: [SQLSelectBuilder]) {
        self.union = .init(all: all, args.map(\.select))
        self.database = database
    }
}

extension SQLDatabase {
    public func union(all: Bool = false, _ args: SQLSelectBuilder...) -> SQLUnionBuilder {
        SQLUnionBuilder(on: self, all: all, args)
    }
}
