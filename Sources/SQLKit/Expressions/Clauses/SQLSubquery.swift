/// An expression which wraps a ``SQLSelect`` query in a ``SQLGroupExpression`` in order to form a syntactically
/// valid subquery expression.
///
/// See also ``SQLSubqueryBuilder``.
///
/// > Note: This type exists because 1) it allows simplifying the syntax of the builder API via type inference, and
/// > 2) design limitations of ``SQLExpression`` prevent enabling said inference in a less roundabout fashion.
public struct SQLSubquery: SQLExpression {
    /// The (sub)query.
    public var subquery: SQLSelect
    
    /// Create a new subquery expression from a select query.
    ///
    /// - Parameter subquery: A ``SQLSelect`` query to use as a subquery.
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
