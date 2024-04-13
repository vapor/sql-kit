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
    public init(
        operand: T,
        lowerBound: U,
        upperBound: V
    ) {
        self.operand = operand
        self.lowerBound = lowerBound
        self.upperBound = upperBound
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

// MARK: - Convenience initializers

extension SQLBetween {
    /// Create a ``SQLBetween`` expression from three bindable values.
    @inlinable
    public init(
        _ operand: some Encodable & Sendable,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some Encodable & Sendable
    ) where T == SQLBind, U == SQLBind, V == SQLBind {
        self.init(operand: .init(operand), lowerBound: .init(lowerBound), upperBound: .init(upperBound))
    }
    
    /// Create an ``SQLBetween`` expression from a bindable value and two ``SQLExpression``s.
    @inlinable
    public init(
        _ operand: some Encodable & Sendable,
        between lowerBound: U,
        and upperBound: V
    ) where T == SQLBind {
        self.init(operand: .init(operand), lowerBound: lowerBound, upperBound: upperBound)
    }
    
    /// Create an ``SQLBetween`` expression from an ``SQLExpression``, a bindable values, and another ``SQLExpression``.
    @inlinable
    public init(
        _ operand: T,
        between lowerBound: some Encodable & Sendable,
        and upperBound: V
    ) where U == SQLBind {
        self.init(operand: operand, lowerBound: .init(lowerBound), upperBound: upperBound)
    }
    
    /// Create an ``SQLBetween`` expression from two ``SQLExpression``s and a bindable value.
    @inlinable
    public init(
        _ operand: T,
        between lowerBound: U,
        and upperBound: some Encodable & Sendable
    ) where V == SQLBind {
        self.init(operand: operand, lowerBound: lowerBound, upperBound: .init(upperBound))
    }
    
    /// Create an ``SQLBetween`` expression from two bindable values and an ``SQLExpression``.
    @inlinable
    public init(
        _ operand: some Encodable & Sendable,
        between lowerBound: some Encodable & Sendable,
        and upperBound: V
    ) where T == SQLBind, U == SQLBind {
        self.init(operand: .init(operand), lowerBound: .init(lowerBound), upperBound: upperBound)
    }
    
    /// Create an ``SQLBetween`` expression from an ``SQLExpression`` and two bindable values.
    @inlinable
    public init(
        _ operand: T,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some Encodable & Sendable
    ) where U == SQLBind, V == SQLBind {
        self.init(operand: operand, lowerBound: .init(lowerBound), upperBound: .init(upperBound))
    }
    
    /// Create an ``SQLBetween`` expression from a bindable value, an ``SQLExpression``, and a bindable value.
    @inlinable
    public init(
        _ operand: some Encodable & Sendable,
        between lowerBound: U,
        and upperBound: some Encodable & Sendable
    ) where T == SQLBind, V == SQLBind {
        self.init(operand: .init(operand), lowerBound: lowerBound, upperBound: .init(upperBound))
    }

    /// Create a ``SQLBetween`` expression from a column name and two bindable values.
    @inlinable
    public init(
        column: String,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some Encodable & Sendable
    ) where T == SQLIdentifier, U == SQLBind, V == SQLBind {
        self.init(operand: .init(column), lowerBound: .init(lowerBound), upperBound: .init(upperBound))
    }
    
    /// Create a ``SQLBetween`` expression from a column name, a bindable value, and an ``SQLExpression``.
    @inlinable
    public init(
        column: String,
        between lowerBound: some Encodable & Sendable,
        and upperBound: V
    ) where T == SQLIdentifier, U == SQLBind {
        self.init(operand: .init(column), lowerBound: .init(lowerBound), upperBound: upperBound)
    }
    
    /// Create a ``SQLBetween`` expression from a column name, an ``SQLExpression``, and a bindable value.
    @inlinable
    public init(
        column: String,
        between lowerBound: U,
        and upperBound: some Encodable & Sendable
    ) where T == SQLIdentifier, V == SQLBind {
        self.init(operand: .init(column), lowerBound: lowerBound, upperBound: .init(upperBound))
    }
    
    /// Create a ``SQLBetween`` expression from a column name and two ``SQLExpression``s.
    @inlinable
    public init(
        column: String,
        between lowerBound: U,
        and upperBound: V
    ) where T == SQLIdentifier {
        self.init(operand: .init(column), lowerBound: lowerBound, upperBound: upperBound)
    }
}

// MARK: - `SQLPredicateBuilder` extensions

extension SQLPredicateBuilder {
    /// Shorthand for `where(SQLBetween(operand, lower, upperBound))`.
    @discardableResult
    @inlinable
    public func `where`(
        _ operand: some Encodable & Sendable,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some Encodable & Sendable
    ) -> Self {
        self.where(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `where(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func `where`(
        _ operand: some SQLExpression,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some Encodable & Sendable
    ) -> Self {
        self.where(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `where(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func `where`(
        _ operand: some Encodable & Sendable,
        between lowerBound: some SQLExpression,
        and upperBound: some Encodable & Sendable
    ) -> Self {
        self.where(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `where(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func `where`(
        _ operand: some Encodable & Sendable,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some SQLExpression
    ) -> Self {
        self.where(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `where(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func `where`(
        _ operand: some SQLExpression,
        between lowerBound: some SQLExpression,
        and upperBound: some Encodable & Sendable
    ) -> Self {
        self.where(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `where(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func `where`(
        _ operand: some SQLExpression,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some SQLExpression
    ) -> Self {
        self.where(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `where(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func `where`(
        _ operand: some Encodable & Sendable,
        between lowerBound: some SQLExpression,
        and upperBound: some SQLExpression
    ) -> Self {
        self.where(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `where(SQLBetween(operand: SQLBind(operand), lowerBound: SQLBind(lowerBound), upperBound: SQLBind(upperBound)))`.
    @discardableResult
    @inlinable
    public func `where`(
        _ operand: some SQLExpression,
        between lowerBound: some SQLExpression,
        and upperBound: some SQLExpression
    ) -> Self {
        self.where(SQLBetween(operand: operand, lowerBound: lowerBound, upperBound: upperBound))
    }

    /// Shorthand for `where(SQLBetween(operand: SQLColumn(column), lowerBound: SQLBind(lowerBound), upperBound: SQLBind(upperBound)))`.
    @discardableResult
    @inlinable
    public func `where`(
        column: String,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some Encodable & Sendable
    ) -> Self {
        self.where(SQLBetween(operand: SQLColumn(column), lowerBound: SQLBind(lowerBound), upperBound: SQLBind(upperBound)))
    }
    
    /// Shorthand for `where(SQLBetween(operand: SQLColumn(column), lowerBound: SQLBind(lowerBound), upperBound: upperBound))`.
    @discardableResult
    @inlinable
    public func `where`(
        column: String,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some SQLExpression
    ) -> Self {
        self.where(SQLBetween(operand: SQLColumn(column), lowerBound: SQLBind(lowerBound), upperBound: upperBound))
    }
    
    /// Shorthand for `where(SQLBetween(operand: SQLColumn(column), lowerBound: lowerBound, upperBound: SQLBind(upperBound)))`.
    @discardableResult
    @inlinable
    public func `where`(
        column: String,
        between lowerBound: some SQLExpression,
        and upperBound: some Encodable & Sendable
    ) -> Self {
        self.where(SQLBetween(operand: SQLColumn(column), lowerBound: lowerBound, upperBound: SQLBind(upperBound)))
    }
    
    /// Shorthand for `where(SQLBetween(operand: SQLColumn(column), lowerBound: lowerBound, upperBound: upperBound))`.
    @discardableResult
    @inlinable
    public func `where`(
        column: String,
        between lowerBound: some SQLExpression,
        and upperBound: some SQLExpression
    ) -> Self {
        self.where(SQLBetween(operand: SQLColumn(column), lowerBound: lowerBound, upperBound: upperBound))
    }
    
    /// Shorthand for `orWhere(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func orWhere(
        _ operand: some Encodable & Sendable,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some Encodable & Sendable
    ) -> Self {
        self.orWhere(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `orWhere(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func orWhere(
        _ operand: some SQLExpression,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some Encodable & Sendable
    ) -> Self {
        self.orWhere(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `orWhere(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func orWhere(
        _ operand: some Encodable & Sendable,
        between lowerBound: some SQLExpression,
        and upperBound: some Encodable & Sendable
    ) -> Self {
        self.orWhere(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `orWhere(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func orWhere(
        _ operand: some Encodable & Sendable,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some SQLExpression
    ) -> Self {
        self.orWhere(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `orWhere(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func orWhere(
        _ operand: some SQLExpression,
        between lowerBound: some SQLExpression,
        and upperBound: some Encodable & Sendable
    ) -> Self {
        self.orWhere(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `orWhere(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func orWhere(
        _ operand: some SQLExpression,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some SQLExpression
    ) -> Self {
        self.orWhere(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `orWhere(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func orWhere(
        _ operand: some Encodable & Sendable,
        between lowerBound: some SQLExpression,
        and upperBound: some SQLExpression
    ) -> Self {
        self.orWhere(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `orWhere(SQLBetween(operand: SQLBind(operand), lowerBound: SQLBind(lowerBound), upperBound: SQLBind(upperBound)))`.
    @discardableResult
    @inlinable
    public func orWhere(
        _ operand: some SQLExpression,
        between lowerBound: some SQLExpression,
        and upperBound: some SQLExpression
    ) -> Self {
        self.orWhere(SQLBetween(operand: operand, lowerBound: lowerBound, upperBound: upperBound))
    }

    /// Shorthand for `orWhere(SQLBetween(operand: SQLColumn(column), lowerBound: SQLBind(lowerBound), upperBound: SQLBind(upperBound)))`.
    @discardableResult
    @inlinable
    public func orWhere(
        column: String,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some Encodable & Sendable
    ) -> Self {
        self.orWhere(SQLBetween(operand: SQLColumn(column), lowerBound: SQLBind(lowerBound), upperBound: SQLBind(upperBound)))
    }
    
    /// Shorthand for `orWhere(SQLBetween(operand: SQLColumn(column), lowerBound: SQLBind(lowerBound), upperBound: upperBound))`.
    @discardableResult
    @inlinable
    public func orWhere(
        column: String,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some SQLExpression
    ) -> Self {
        self.orWhere(SQLBetween(operand: SQLColumn(column), lowerBound: SQLBind(lowerBound), upperBound: upperBound))
    }
    
    /// Shorthand for `orWhere(SQLBetween(operand: SQLColumn(column), lowerBound: lowerBound, upperBound: SQLBind(upperBound)))`.
    @discardableResult
    @inlinable
    public func orWhere(
        column: String,
        between lowerBound: some SQLExpression,
        and upperBound: some Encodable & Sendable
    ) -> Self {
        self.orWhere(SQLBetween(operand: SQLColumn(column), lowerBound: lowerBound, upperBound: SQLBind(upperBound)))
    }
    
    /// Shorthand for `orWhere(SQLBetween(operand: SQLColumn(column), lowerBound: lowerBound, upperBound: upperBound))`.
    @discardableResult
    @inlinable
    public func orWhere(
        column: String,
        between lowerBound: some SQLExpression,
        and upperBound: some SQLExpression
    ) -> Self {
        self.orWhere(SQLBetween(operand: SQLColumn(column), lowerBound: lowerBound, upperBound: upperBound))
    }
}

// MARK: - `SQLSecondaryPredicateBuilder` extensions

extension SQLSecondaryPredicateBuilder {
    /// Shorthand for `having(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func having(
        _ operand: some Encodable & Sendable,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some Encodable & Sendable
    ) -> Self {
        self.having(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `having(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func having(
        _ operand: some SQLExpression,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some Encodable & Sendable
    ) -> Self {
        self.having(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `having(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func having(
        _ operand: some Encodable & Sendable,
        between lowerBound: some SQLExpression,
        and upperBound: some Encodable & Sendable
    ) -> Self {
        self.having(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `having(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func having(
        _ operand: some Encodable & Sendable,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some SQLExpression
    ) -> Self {
        self.having(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `having(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func having(
        _ operand: some SQLExpression,
        between lowerBound: some SQLExpression,
        and upperBound: some Encodable & Sendable
    ) -> Self {
        self.having(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `having(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func having(
        _ operand: some SQLExpression,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some SQLExpression
    ) -> Self {
        self.having(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `having(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func having(
        _ operand: some Encodable & Sendable,
        between lowerBound: some SQLExpression,
        and upperBound: some SQLExpression
    ) -> Self {
        self.having(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `having(SQLBetween(operand: SQLBind(operand), lowerBound: SQLBind(lowerBound), upperBound: SQLBind(upperBound)))`.
    @discardableResult
    @inlinable
    public func having(
        _ operand: some SQLExpression,
        between lowerBound: some SQLExpression,
        and upperBound: some SQLExpression
    ) -> Self {
        self.having(SQLBetween(operand: operand, lowerBound: lowerBound, upperBound: upperBound))
    }

    /// Shorthand for `having(SQLBetween(operand: SQLColumn(column), lowerBound: SQLBind(lowerBound), upperBound: SQLBind(upperBound)))`.
    @discardableResult
    @inlinable
    public func having(
        column: String,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some Encodable & Sendable
    ) -> Self {
        self.having(SQLBetween(operand: SQLColumn(column), lowerBound: SQLBind(lowerBound), upperBound: SQLBind(upperBound)))
    }
    
    /// Shorthand for `having(SQLBetween(operand: SQLColumn(column), lowerBound: SQLBind(lowerBound), upperBound: upperBound))`.
    @discardableResult
    @inlinable
    public func having(
        column: String,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some SQLExpression
    ) -> Self {
        self.having(SQLBetween(operand: SQLColumn(column), lowerBound: SQLBind(lowerBound), upperBound: upperBound))
    }
    
    /// Shorthand for `having(SQLBetween(operand: SQLColumn(column), lowerBound: lowerBound, upperBound: SQLBind(upperBound)))`.
    @discardableResult
    @inlinable
    public func having(
        column: String,
        between lowerBound: some SQLExpression,
        and upperBound: some Encodable & Sendable
    ) -> Self {
        self.having(SQLBetween(operand: SQLColumn(column), lowerBound: lowerBound, upperBound: SQLBind(upperBound)))
    }
    
    /// Shorthand for `having(SQLBetween(operand: SQLColumn(column), lowerBound: lowerBound, upperBound: upperBound))`.
    @discardableResult
    @inlinable
    public func having(
        column: String,
        between lowerBound: some SQLExpression,
        and upperBound: some SQLExpression
    ) -> Self {
        self.having(SQLBetween(operand: SQLColumn(column), lowerBound: lowerBound, upperBound: upperBound))
    }
    
    /// Shorthand for `orHaving(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func orHaving(
        _ operand: some Encodable & Sendable,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some Encodable & Sendable
    ) -> Self {
        self.orHaving(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `orHaving(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func orHaving(
        _ operand: some SQLExpression,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some Encodable & Sendable
    ) -> Self {
        self.orHaving(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `orHaving(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func orHaving(
        _ operand: some Encodable & Sendable,
        between lowerBound: some SQLExpression,
        and upperBound: some Encodable & Sendable
    ) -> Self {
        self.orHaving(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `orHaving(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func orHaving(
        _ operand: some Encodable & Sendable,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some SQLExpression
    ) -> Self {
        self.orHaving(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `orHaving(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func orHaving(
        _ operand: some SQLExpression,
        between lowerBound: some SQLExpression,
        and upperBound: some Encodable & Sendable
    ) -> Self {
        self.orHaving(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `orHaving(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func orHaving(
        _ operand: some SQLExpression,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some SQLExpression
    ) -> Self {
        self.orHaving(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `orHaving(SQLBetween(operand, lowerBound, upperBound))`.
    @discardableResult
    @inlinable
    public func orHaving(
        _ operand: some Encodable & Sendable,
        between lowerBound: some SQLExpression,
        and upperBound: some SQLExpression
    ) -> Self {
        self.orHaving(SQLBetween(operand, between: lowerBound, and: upperBound))
    }

    /// Shorthand for `orHaving(SQLBetween(operand: SQLBind(operand), lowerBound: SQLBind(lowerBound), upperBound: SQLBind(upperBound)))`.
    @discardableResult
    @inlinable
    public func orHaving(
        _ operand: some SQLExpression,
        between lowerBound: some SQLExpression,
        and upperBound: some SQLExpression
    ) -> Self {
        self.orHaving(SQLBetween(operand: operand, lowerBound: lowerBound, upperBound: upperBound))
    }

    /// Shorthand for `orHaving(SQLBetween(operand: SQLColumn(column), lowerBound: SQLBind(lowerBound), upperBound: SQLBind(upperBound)))`.
    @discardableResult
    @inlinable
    public func orHaving(
        column: String,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some Encodable & Sendable
    ) -> Self {
        self.orHaving(SQLBetween(operand: SQLColumn(column), lowerBound: SQLBind(lowerBound), upperBound: SQLBind(upperBound)))
    }
    
    /// Shorthand for `orHaving(SQLBetween(operand: SQLColumn(column), lowerBound: SQLBind(lowerBound), upperBound: upperBound))`.
    @discardableResult
    @inlinable
    public func orHaving(
        column: String,
        between lowerBound: some Encodable & Sendable,
        and upperBound: some SQLExpression
    ) -> Self {
        self.orHaving(SQLBetween(operand: SQLColumn(column), lowerBound: SQLBind(lowerBound), upperBound: upperBound))
    }
    
    /// Shorthand for `orHaving(SQLBetween(operand: SQLColumn(column), lowerBound: lowerBound, upperBound: SQLBind(upperBound)))`.
    @discardableResult
    @inlinable
    public func orHaving(
        column: String,
        between lowerBound: some SQLExpression,
        and upperBound: some Encodable & Sendable
    ) -> Self {
        self.orHaving(SQLBetween(operand: SQLColumn(column), lowerBound: lowerBound, upperBound: SQLBind(upperBound)))
    }
    
    /// Shorthand for `orHaving(SQLBetween(operand: SQLColumn(column), lowerBound: lowerBound, upperBound: upperBound))`.
    @discardableResult
    @inlinable
    public func orHaving(
        column: String,
        between lowerBound: some SQLExpression,
        and upperBound: some SQLExpression
    ) -> Self {
        self.orHaving(SQLBetween(operand: SQLColumn(column), lowerBound: lowerBound, upperBound: upperBound))
    }
}
