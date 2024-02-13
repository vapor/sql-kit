/// Wraps a ``SQLSelect`` query in a ``SQLGroupExpression`` to form a syntactically valid subquery.
public struct SQLSubquery: SQLExpression {
    /// The (sub)query.
    public var subquery: SQLSelect
    
    @inlinable
    public init(_ subquery: SQLSelect) {
        self.subquery = subquery
    }

    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        SQLGroupExpression(self.subquery).serialize(to: &serializer)
    }
}
