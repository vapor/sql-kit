/// An ``SQLExpression`` which constructs SQL of the form `<operand> BETWEEN <lowerBound> AND <upperBound>`.
public struct SQLBetween<T: SQLExpression, U: SQLExpression, V: SQLExpression>: SQLExpression {
    public let operand: T
    public let lowerBound: U
    public let upperBound: V

    /// Create a ``SQLBetween`` expression from three ``SQLExpression``s.
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
