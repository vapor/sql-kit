/// An expression representing two or more `SELECT` queries joined by `UNION` clauses. Used to merge the results of
/// multiple queries into a single result set.
///
/// ```sql
/// (SELECT ...)
/// UNION ALL
/// (SELECT ...)
/// INTERSECT DISTINCT
/// (SELECT ...)
/// EXCEPT ALL
/// (SELECT ...)
/// ```
///
/// There are numerous variations in support and syntax for `UNION` joiners between dialects; this expression respects
/// dialect differences to the extent possible but will someimtes generate invalid SQL if an operation unsupported by
/// the current dialect is described by its inputs.
///
/// See ``SQLUnionBuilder``.
public struct SQLUnion: SQLExpression {
    /// An optional common table expression group.
    public var tableExpressionGroup: SQLCommonTableExpressionGroup?
    
    /// The required first query of the union.
    public var initialQuery: SQLSelect
    
    /// Zero or more additional queries whose results are to be combined with that of the initial query and
    /// associated joiner expressions describing the combining operation.
    ///
    /// This is conceptually similar to ``SQLSelect/joins`` in that each item in the list represents a method and an
    /// additional expression.
    ///
    /// See ``SQLSelect`` and ``SQLUnionJoiner``.
    public var unions: [(SQLUnionJoiner, SQLSelect)]
    
    /// Zero or more columns or expressions specifying sort keys and directionalities for the overall result rows.
    ///
    /// See ``SQLDirection``.
    public var orderBys: [any SQLExpression] = []
    
    /// If not `nil`, limits the number of result rows returned. Applies _after_ ``offset`` (if specified).
    ///
    /// Although the type of this property is `Int`, it is invalid to specify a negative value.
    public var limit: Int? = nil
    
    /// If not `nil`, skips the given number of result rows before starting to return results.
    ///
    /// Although the type of this property is `Int`, it is invalid to specify a negative value.
    public var offset: Int? = nil

    /// Create a new set of combined queries.
    ///
    /// See ``SQLSelect`` and ``SQLUnionJoiner``.
    ///
    /// - Parameters:
    ///   - initialQuery: The first query of the set.
    ///   - unions: A list of zero or more pairs of joiner expressions and additional queries.
    @inlinable
    public init(initialQuery: SQLSelect, unions: [(SQLUnionJoiner, SQLSelect)] = []) {
        self.initialQuery = initialQuery
        self.unions = unions
    }

    /// Add an additional query to the union using the `UNION` or `UNION ALL` joiner.
    ///
    /// - Parameters:
    ///   - query: The query to add.
    ///   - all: If true, use `UNION ALL` as the joiner, otherwise use `UNION DISTINCT`.
    @inlinable
    public mutating func add(_ query: SQLSelect, all: Bool) {
        self.add(query, joiner: .init(type: all ? .unionAll : .union))
    }
    
    /// Add an additional query to the union using the provided joiner.
    ///
    /// - Parameters:
    ///   - query: The query to add.
    ///   - joiner: THe joiner to use. See ``SQLUnionJoiner``.
    @inlinable
    public mutating func add(_ query: SQLSelect, joiner: SQLUnionJoiner) {
        self.unions.append((joiner, query))
    }

    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement { stmt in
            stmt.append(self.tableExpressionGroup)
            
            guard !self.unions.isEmpty else {
                /// If no unions are specified, serialize as a plain query even if the dialect would otherwise
                /// specify the use of parenthesized subqueries. Ignores orderBys, limit, and offset.
                return stmt.append(self.initialQuery)
            }
            
            let parenthesize = stmt.dialect.unionFeatures.contains(.parenthesizedSubqueries)

            stmt.append(parenthesize ? SQLGroupExpression(self.initialQuery) : self.initialQuery)
            for (joiner, query) in self.unions {
                stmt.append(joiner, parenthesize ? SQLGroupExpression(query) : query)
            }
            if !self.orderBys.isEmpty {
                stmt.append("ORDER BY", SQLList(self.orderBys))
            }
            if let limit = self.limit {
                stmt.append("LIMIT", SQLLiteral.numeric("\(limit)"))
            }
            if let offset = self.offset {
                stmt.append("OFFSET", SQLLiteral.numeric("\(offset)"))
            }
        }
    }
}

/// An expression representing one of the six supported query union operations.
///
/// If the current dialect does not support a given operation, no SQL is output, typically resulting in invalid
/// syntax in the overall query.
///
/// See ``SQLUnion`` and ``SQLUnionBuilder``.
public struct SQLUnionJoiner: SQLExpression {
    /// The supported query union operations.
    public enum `Type`: Equatable, CaseIterable, Sendable {
        /// The `UNION` operation, also called `UNION DISTINCT`.
        ///
        /// Returns all result rows from both sides of the union, de-duplicating the combined set.
        case union
        
        /// The `UNION ALL` operation.
        ///
        /// Returns all result rows from both sides of the union, including duplicates.
        case unionAll
        
        /// The `INTERSECT` or `INTERSECT DISTINCT` operation.
        ///
        /// Returns all result rows which occur on both sides of the union, de-duplicating the results.
        case intersect
        
        /// The `INTERSECT ALL` operation.
        ///
        /// Returns all result rows which occur on both sides of the union, including duplicates.
        case intersectAll
        
        /// The `EXCEPT` or `EXCEPT DISTINCT` operation.
        ///
        /// Returns all result rows which occur _only_ on the left side of the union, de-duplcating the results.
        case except
        
        /// The `EXCEPT ALL` operation.
        ///
        /// Returns all result rows which occur _only_ on the left side of the union, including duplicates.
        case exceptAll
    }
    
    /// The operation this joiner describes.
    public var type: `Type`
    
    /// Create a new union joiner expression.
    ///
    /// - Parameter type: The operation the joiner describes.
    @inlinable
    public init(type: `Type`) {
        self.type = type
    }
    
    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement { statement in
            func write(keyword: String, if flag: SQLUnionFeatures, uniqued: Bool) {
                if !statement.dialect.unionFeatures.contains(flag) {
                    return statement.logger.debug("The \(statement.dialect.name) dialect does not support \(keyword)\(uniqued ? " ALL" : "").")
                }
                statement.append(keyword)
                if !uniqued {
                    statement.append("ALL")
                } else if statement.dialect.unionFeatures.contains(.explicitDistinct) {
                    statement.append("DISTINCT")
                }
            }
            switch self.type {
            case .union:        write(keyword: "UNION",     if: .union,        uniqued: true)
            case .unionAll:     write(keyword: "UNION",     if: .unionAll,     uniqued: false)
            case .intersect:    write(keyword: "INTERSECT", if: .intersect,    uniqued: true)
            case .intersectAll: write(keyword: "INTERSECT", if: .intersectAll, uniqued: false)
            case .except:       write(keyword: "EXCEPT",    if: .except,       uniqued: true)
            case .exceptAll:    write(keyword: "EXCEPT",    if: .exceptAll,    uniqued: false)
            }
        }
    }
}
