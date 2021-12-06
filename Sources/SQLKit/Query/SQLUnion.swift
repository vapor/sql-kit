public struct SQLUnion: SQLExpression {
    public var initialQuery: SQLSelect
    public var unions: [(SQLUnionJoiner, SQLSelect)]

    public init(initialQuery: SQLSelect, unions: [(SQLUnionJoiner, SQLSelect)] = []) {
        self.initialQuery = initialQuery
        self.unions = unions
    }

    public mutating func add(_ query: SQLSelect, all: Bool) {
        self.unions.append((.init(all: all), query))
    }

    public func serialize(to serializer: inout SQLSerializer) {
        assert(!self.unions.isEmpty, "Serializing a union with only one query is invalid.")
        SQLGroupExpression(self.initialQuery).serialize(to: &serializer)
        self.unions
            .forEach { (joiner, select) in
                joiner.serialize(to: &serializer)
                SQLGroupExpression(select).serialize(to: &serializer)
            }
    }
}

public struct SQLUnionJoiner: SQLExpression {
    public var all: Bool
    
    public init(all: Bool) {
        self.all = all
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write(" UNION\(self.all ? " ALL" : "") ")
    }
}

