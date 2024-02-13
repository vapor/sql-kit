/// An ``SQLExpression`` which constructs SQL of the form `<operand> BETWEEN <lowerBound> AND <upperBound>`.
///
/// This syntax is a more readable way of expressing the usually identical SQL construct
/// `((operand >= lowerBound) AND (operand <= upperBound))`. However, it is functionally distinct from the
/// dual-condition syntax in the case that the `operand` is a nondeterministic expression whose results
/// can or may change per-evaluation (such as `RANDOM()`), in which case `BETWEEN` will evaluate it exactly
/// once rather than twice.
///
/// > Note: While it would be possible to use conditional conformance to `Strideable` to enable translating
/// > Swift `RangeExpression`s into ``SQLBetween`` expressions, this is considered slightly above the intended
/// > level of SQLKit's API.
public struct SQLBetween<T: SQLExpression, U: SQLExpression, V: SQLExpression>: SQLExpression {
    public let operand: T
    public let lowerBound: U
    public let upperBound: V

    /// Create a ``SQLBetween`` expression from three ``SQLExpression``s.
    /// 
    /// - Parameters:
    ///   - operand: The value to evaluate the range against.
    ///   - lowerBound: The lower bound of the range.
    ///   - upperBound: The upper bound of the range.
    @inlinable
    public init(operand: T, lowerBound: U, upperBound: V) {
        self.operand = operand
        self.lowerBound = lowerBound
        self.upperBound = upperBound
    }

    /// Create a ``SQLBetween`` expression from three bindable values.
    @inlinable
    public init(_ operand: some Encodable & Sendable, _ lowerBound: some Encodable & Sendable, and upperBound: some Encodable & Sendable)
        where T == SQLBind, U == SQLBind, V == SQLBind
    {
        self.init(operand: SQLBind(operand), lowerBound: SQLBind(lowerBound), upperBound: SQLBind(upperBound))
    }

    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append(self.operand)
            $0.append("BETWEEN", self.lowerBound)
            $0.append("AND",     self.upperBound)
        }
    }
}

extension SQLPredicateBuilder {
    /// Shorthand for `where(SQLBetween(operand, lower, upper))`.
    @discardableResult
    @inlinable
    public func `where`(_ operand: some Encodable & Sendable, between lower: some Encodable & Sendable, and upper: some Encodable & Sendable) -> Self {
        self.where(SQLBetween(operand: SQLBind(operand), lowerBound: SQLBind(lower), upperBound: SQLBind(upper)))
    }

    /// Shorthand for `where(SQLBetween(operand: operand, lowerBound: SQLBind(lower), upperBound: SQLBind(upper)))`.
    @discardableResult
    @inlinable
    public func `where`(_ operand: some SQLExpression, between lower: some Encodable & Sendable, and upper: some Encodable & Sendable) -> Self {
        self.where(SQLBetween(operand: operand, lowerBound: SQLBind(lower), upperBound: SQLBind(upper)))
    }

    /// Shorthand for `where(SQLBetween(operand: SQLBind(operand), lowerBound: lower, upperBound: SQLBind(upper)))`.
    @discardableResult
    @inlinable
    public func `where`(_ operand: some Encodable & Sendable, between lower: some SQLExpression, and upper: some Encodable & Sendable) -> Self {
        self.where(SQLBetween(operand: SQLBind(operand), lowerBound: lower, upperBound: SQLBind(upper)))
    }

    /// Shorthand for `where(SQLBetween(operand: SQLBind(operand), lowerBound: SQLBind(lower), upperBound: upper))`.
    @discardableResult
    @inlinable
    public func `where`(_ operand: some Encodable & Sendable, between lower: some Encodable & Sendable, and upper: some SQLExpression) -> Self {
        self.where(SQLBetween(operand: SQLBind(operand), lowerBound: SQLBind(lower), upperBound: upper))
    }

    /// Shorthand for `where(SQLBetween(operand: operand, lowerBound: lower, upperBound: SQLBind(upper)))`.
    @discardableResult
    @inlinable
    public func `where`(_ operand: some SQLExpression, between lower: some SQLExpression, and upper: some Encodable & Sendable) -> Self {
        self.where(SQLBetween(operand: operand, lowerBound: lower, upperBound: SQLBind(upper)))
    }

    /// Shorthand for `where(SQLBetween(operand: operand, lowerBound: SQLBind(lower), upperBound: upper))`.
    @discardableResult
    @inlinable
    public func `where`(_ operand: some SQLExpression, between lower: some Encodable & Sendable, and upper: some SQLExpression) -> Self {
        self.where(SQLBetween(operand: operand, lowerBound: SQLBind(lower), upperBound: upper))
    }

    /// Shorthand for `where(SQLBetween(operand: SQLBind(operand), lowerBound: lower, upperBound: upper))`.
    @discardableResult
    @inlinable
    public func `where`(_ operand: some Encodable & Sendable, between lower: some SQLExpression, and upper: some SQLExpression) -> Self {
        self.where(SQLBetween(operand: SQLBind(operand), lowerBound: lower, upperBound: upper))
    }

    /// Shorthand for `where(SQLBetween(operand: SQLBind(operand), lowerBound: SQLBind(lower), upperBound: SQLBind(upper)))`.
    @discardableResult
    @inlinable
    public func `where`(_ operand: some SQLExpression, between lower: some SQLExpression, and upper: some SQLExpression) -> Self {
        self.where(SQLBetween(operand: operand, lowerBound: lower, upperBound: upper))
    }
}
