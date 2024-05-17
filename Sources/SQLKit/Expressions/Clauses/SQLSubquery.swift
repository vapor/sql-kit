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

/// A trivial copy of ``SQLSubquery`` with a different type for its subquery property.
///
/// As with ``SQLCommonUnionBuilder``, this type is only necessary because of design oversights made when the original
/// support for unions was added (the way subquery support, which was not implemented at the time, would work was not
/// anticipated, so some types got more hardcoded than was wise); we can't fix them without breaking public API, so
/// this annoying duplication of code is used as a workaround.
///
/// See also ``SQLUnionSubqueryBuilder``.
public struct SQLUnionSubquery: SQLExpression {
    /// The (sub)query.
    public var subquery: SQLUnion
    
    /// Create a new subquery expression from a select query.
    ///
    /// - Parameter subquery: A ``SQLUnion`` query to use as a subquery.
    @inlinable
    public init(_ subquery: SQLUnion) {
        self.subquery = subquery
    }

    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        SQLGroupExpression(self.subquery).serialize(to: &serializer)
    }
}
