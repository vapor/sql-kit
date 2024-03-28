/// A pair of expressions, one describing a query sort key and the other a directionality for that key.
///
/// Use ``SQLDirection`` to describe directionality unless a nonstandard value is needed.
///
/// This expression type is an implementation detail of ``SQLPartialResultBuilder`` and should not have been
/// made public API. Users should avoid using this type.
public struct SQLOrderBy: SQLExpression {
    /// A sorting key.
    public var expression: any SQLExpression
    
    /// A sort directionality.
    ///
    /// See ``SQLDirection``.
    public var direction: any SQLExpression
    
    /// Creates a new ordering clause.
    ///
    /// - Parameters:
    ///   - expression: The sorting key.
    ///   - direction: The sort directionality.
    @inlinable
    public init(expression: any SQLExpression, direction: any SQLExpression) {
        self.expression = expression
        self.direction = direction
    }
    
    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        /// The mere fact that the serialization of this clause is this trivial underscores how excessively verbose
        /// making use of it is and why it is superfluous in a better-designed API.
        serializer.statement {
            $0.append(self.expression, self.direction)
        }
    }
}
