public final class SQLUnionBuilder: SQLQueryBuilder {
    public var query: SQLExpression {
        return self.union
    }

    public var union: SQLUnion
    public var database: SQLDatabase

    public init(on database: SQLDatabase,
                _ args: [SQLSelectBuilder],
                all: Bool = false) {
        self.union = .init(args.map(\.select), all: all)
        self.database = database
    }
}

extension SQLDatabase {
    public func union(_ args: SQLSelectBuilder...) -> SQLUnionBuilder {
        SQLUnionBuilder(on: self, args)
    }

    public func union(all args: SQLSelectBuilder...) -> SQLUnionBuilder {
        SQLUnionBuilder(on: self, args, all: true)
    }
}
