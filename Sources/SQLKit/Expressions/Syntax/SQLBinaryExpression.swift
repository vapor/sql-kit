/// A fundamental syntactical expression - a left and right operand joined by an infix operator.
///
/// This construct forms the basis of most comparisons, conditionals, and compounds which can be
/// represented by an expression.
///
/// For example, the expression `foo = 1 AND bar <> 'baz' OR bop - 5 NOT IN (1, 3)` can be represented
/// in terms of nested ``SQLBinaryExpression``s (note that there is more than one "correct" way to nest
/// this particular example):
///
/// ```swift
/// let expr = SQLBinaryExpression(
///     SQLBinaryExpression(SQLColumn("foo"), .equal, SQLLiteral.numeric("1")),
///     .and,
///     SQLBinaryExpression(
///         SQLBinaryExpression(SQLColumn("bar"), .notEqual, SQLLiteral.string("baz")),
///         .or,
///         SQLBinaryExpression(
///             SQLBinaryExpression(SQLColumn("bop"), .subtract, SQLLiteral.numeric("5")),
///             .notIn,
///             SQLGroupExpression(SQLLiteral.numeric("1"), SQLLiteral.numeric("3"))
///         )
///     )
/// )
/// ```
public struct SQLBinaryExpression: SQLExpression {
    /// The left-side operand of the expression.
    public let left: any SQLExpression
    
    /// The operator joining the left and right operands.
    public let op: any SQLExpression
    
    /// The right-side operand of the expression.
    public let right: any SQLExpression
    
    /// Create an ``SQLBinaryExpression`` from component expressions.
    ///
    /// - Parameters:
    ///   - left: The left-side oeprand.
    ///   - op: The operator.
    ///   - right: The right-side operand.
    @inlinable
    public init(
        left: any SQLExpression,
        op: any SQLExpression,
        right: any SQLExpression
    ) {
        self.left = left
        self.op = op
        self.right = right
    }
    
    /// Create an ``SQLBinaryExpression`` from two operand expressions and a predefined binary operator.
    ///
    /// - Parameters:
    ///   - left: The left-side operand.
    ///   - op: The binary operator.
    ///   - right: The right-side operand.
    @inlinable
    public init(
        _ left: any SQLExpression,
        _ op: SQLBinaryOperator,
        _ right: any SQLExpression
    ) {
        self.init(left: left, op: op, right: right)
    }

    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append(self.left)
            $0.append(self.op)
            $0.append(self.right)
        }
    }
}
