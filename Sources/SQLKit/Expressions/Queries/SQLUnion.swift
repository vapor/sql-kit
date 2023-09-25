public struct SQLUnion: SQLExpression {
    public var initialQuery: SQLSelect
    public var unions: [(SQLUnionJoiner, SQLSelect)]
    
    /// Zero or more `ORDER BY` clauses.
    public var orderBys: [any SQLExpression]
    
    /// If set, limits the maximum number of results.
    public var limit: Int?
    
    /// If set, offsets the results.
    public var offset: Int?

    @inlinable
    public init(initialQuery: SQLSelect, unions: [(SQLUnionJoiner, SQLSelect)] = []) {
        self.initialQuery = initialQuery
        self.unions = unions
        self.limit = nil
        self.offset = nil
        self.orderBys = []
    }

    @inlinable
    public mutating func add(_ query: SQLSelect, all: Bool) {
        self.add(query, joiner: .init(type: all ? .unionAll : .union))
    }
    
    @inlinable
    public mutating func add(_ query: SQLSelect, joiner: SQLUnionJoiner) {
        self.unions.append((joiner, query))
    }

    public func serialize(to serializer: inout SQLSerializer) {
        guard !self.unions.isEmpty else {
            return initialQuery.serialize(to: &serializer)
        }

        serializer.statement { statement in
            func appendQuery(_ query: SQLSelect) {
                if statement.dialect.unionFeatures.contains(.parenthesizedSubqueries) {
                    statement.append(SQLGroupExpression(query))
                } else {
                    statement.append(query)
                }
            }

            appendQuery(self.initialQuery)
            self.unions.forEach { joiner, query in
                statement.append(joiner)
                appendQuery(query)
            }
            
            if !self.orderBys.isEmpty {
                statement.append("ORDER BY")
                statement.append(SQLList(self.orderBys))
            }
            if let limit = self.limit {
                statement.append("LIMIT")
                statement.append(limit.description)
            }
            if let offset = self.offset {
                statement.append("OFFSET")
                statement.append(offset.description)
            }
        }
    }
}

/// - Note: There's no technical reason that this is an `enum` nested in a `struct` rather than just a bare
///   `enum`. It's this way because Gwynne merged a PR for an early version of this code and it was released
///   publicly before she realized there were several missing pieces; changing it now would be potentially
///   source-breaking, so it has to be left like this until the next major version.
public struct SQLUnionJoiner: SQLExpression {
    public enum `Type`: Equatable, CaseIterable {
        case union, unionAll, intersect, intersectAll, except, exceptAll
    }
    
    public var type: `Type`

    @available(*, deprecated, message: "Use .type` instead.")
    @inlinable
    public var all: Bool {
        get { [.unionAll, .intersectAll, .exceptAll].contains(self.type) }
        set { switch (self.type, newValue) {
            case (.union, true): self.type = .unionAll
            case (.unionAll, false): self.type = .union
            case (.intersect, true): self.type = .intersectAll
            case (.intersectAll, false): self.type = .intersect
            case (.except, true): self.type = .exceptAll
            case (.exceptAll, false): self.type = .except
            default: break
        } }
    }
    
    @available(*, deprecated, message: "Use .init(type:)` instead.")
    @inlinable
    public init(all: Bool) {
        self.init(type: all ? .unionAll : .union)
    }
    
    @inlinable
    public init(type: `Type`) {
        self.type = type
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        func serialize(keyword: String, if flag: SQLUnionFeatures, uniqued: Bool, to statement: inout SQLStatement) {
            if !statement.dialect.unionFeatures.contains(flag) {
                return print("WARNING: The \(statement.dialect.name) dialect does not support \(keyword)\(uniqued ? " ALL" :"")!")
            }
            statement.append(keyword)
            if !uniqued {
                statement.append("ALL")
            } else if statement.dialect.unionFeatures.contains(.explicitDistinct) {
                statement.append("DISTINCT")
            }
        }
        serializer.statement {
            switch self.type {
            case .union:        serialize(keyword: "UNION", if: .union, uniqued: true, to: &$0)
            case .unionAll:     serialize(keyword: "UNION", if: .unionAll, uniqued: false, to: &$0)
            case .intersect:    serialize(keyword: "INTERSECT", if: .intersect, uniqued: true, to: &$0)
            case .intersectAll: serialize(keyword: "INTERSECT", if: .intersectAll, uniqued: false, to: &$0)
            case .except:       serialize(keyword: "EXCEPT", if: .except, uniqued: true, to: &$0)
            case .exceptAll:    serialize(keyword: "EXCEPT", if: .exceptAll, uniqued: false, to: &$0)
            }
        }
    }
}

