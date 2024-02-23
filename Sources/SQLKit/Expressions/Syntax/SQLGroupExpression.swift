/// A fundamental syntactical expression - an arbitrary expression or list of expressions, surroudned by parenthesis.
///
/// This construct provides "grouping" syntax in numerous contexts. When a "group" contains more than one
/// subexpression, all subexpressions are joined using ``SQLList`` with the default separator. See
/// ``SQLList/init(_:separator:)`` for aadditional information.
///
/// Example usage:
///
/// ```swift
/// try await database.select()
///     .column(...)
///     .where("foo", .in, SQLGroupExpression(SQLBind(foo), SQLBind(bar)))
///     ...
/// // Generated SQL: `SELECT ... FROM .. WHERE "foo" IN ($0, $1)`.
/// ```
public struct SQLGroupExpression: SQLExpression {
    /// The potentially empty list of expressions to group.
    ///
    /// When there is more than one expression in the list, they are wrapped with an ``SQLList`` before serialization.
    public let expressions: [any SQLExpression]
    
    /// Create a group expression with a single subexpresion.
    ///
    /// - Parameter expression: The subexpression to parenthesize.
    @inlinable
    public init(_ expression: any SQLExpression) {
        self.expressions = [expression]
    }
    
    /// Create a group expression with a list of zero or more subexpressions.
    ///
    /// When more than one expression is provided, they are wrapped with a default ``SQLList`` before serialization,
    /// resulting in a parenthesized comma-separated list.
    ///
    /// - Parameter expressions: The list of expressions to parenthesize.
    @inlinable
    public init(_ expressions: [any SQLExpression]) {
        self.expressions = expressions
    }
    
    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write("(")
        SQLList(self.expressions).serialize(to: &serializer)
        serializer.write(")")
    }
}
