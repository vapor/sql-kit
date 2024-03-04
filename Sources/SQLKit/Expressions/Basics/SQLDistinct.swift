/// An expression representing the subexpression of an aggregate function call which specifies whether the aggregate
/// groups over all result rows or only distinct rows.
///
/// This expression is another example of incomplete API design; it should properly be implemented as an expression
/// called `SQLAggregateFunction` which includes the aggregate function name as part of the expression and allows
/// specifying `ORDER BY` and `FILTER` clauses as supported by various dialects. An example of using it in the current
/// implementation:
///
/// ```sql
/// let count = try await database.select()
///     .column(SQLFunction("count", SQLDistinct(SQLColumn("column1"))), as: "count")
///     .first(decodingColumn: "count", as: Int.self)!
/// ```
public struct SQLDistinct: SQLExpression {
    /// Zero or more identifiers and/or expressions to treat as a combined uniquing key.
    public let args: [any SQLExpression]
    
    /// Shorthand for `SQLDistinct(SQLLiteral.all)`.
    @inlinable
    public static var all: SQLDistinct {
        .init(SQLLiteral.all)
    }

    /// Create a `DISTINCT` expression with a list of string identifiers.
    @inlinable
    public init(_ args: String...) {
        self.init(args)
    }
    
    /// Create a `DISTINCT` expression with a list of string identifiers.
    @inlinable
    public init(_ args: [String]) {
        self.init(args.map(SQLIdentifier.init(_:)))
    }
    
    /// Create a `DISTINCT` expression with a list of expressions.
    @inlinable
    public init(_ args: any SQLExpression...) {
        self.init(args)
    }
    
    /// Create a `DISTINCT` expression with a list of expressions.
    @inlinable
    public init(_ args: [any SQLExpression]) {
        self.args = args
    }

    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        guard !self.args.isEmpty else {
            return
        }
        serializer.statement {
            $0.append("DISTINCT", SQLList(self.args))
        }
    }
}
