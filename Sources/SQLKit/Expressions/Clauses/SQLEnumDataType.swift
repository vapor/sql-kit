/// Represents a data type which specifies an enumeration in the database.
/// 
/// Used to hide some of the complexity in supporting ``SQLEnumSyntax/inline`` enum syntax. If the dialect does not
/// use inline syntax, reverts to ``SQLDataType/text``.
///
/// Instances of this expression are typically embedded within a ``SQLDataType`` ``SQLDataType/custom(_:)`` case. See
/// ``SQLDataType/enum(_:)-677jw``, ``SQLDataType/enum(_:)-6k432``, and ``SQLDataType/enum(_:)-9jlju``,
public struct SQLEnumDataType: SQLExpression {
    /// The individual cases defined by the enumeration.
    @usableFromInline
    var cases: [any SQLExpression]

    /// Create a new enumeration type with a list of cases.
    ///
    /// - Parameter cases: The list of cases in the enumeration.
    @inlinable
    public init(cases: [String]) {
        self.init(cases: cases.map(SQLLiteral.string(_:)))
    }

    /// Create a new enumeration type with a list of cases.
    ///
    /// - Parameter cases: The list of cases in the enumeration.
    @inlinable
    public init(cases: [any SQLExpression]) {
        self.cases = cases
    }

    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            switch $0.dialect.enumSyntax {
            case .inline:
                $0.append("ENUM", SQLGroupExpression(self.cases))
            case .typeName:
                $0.logger.warning("SQLEnumDataType is not intended for use with PostgreSQL-style enum syntax.")
                fallthrough
            case .unsupported:
                // Do not warn for this case; just transparently fall back to text.
                $0.append(SQLDataType.text)
            }
        }
    }
}

extension SQLDataType {
    /// Translates to an enumeration including the specified list of cases.
    ///
    /// - Parameter cases: The list of cases in the numeration.
    /// - Returns: An appropriate ``SQLDataType``.
    @inlinable
    public static func `enum`(_ cases: String...) -> Self {
        self.enum(cases)
    }

    /// Translates to an enumeration including the specified list of cases.
    ///
    /// - Parameter cases: The list of cases in the numeration.
    /// - Returns: An appropriate ``SQLDataType``.
    @inlinable
    public static func `enum`(_ cases: [String]) -> Self {
        self.enum(cases.map(SQLLiteral.string(_:)))
    }

    /// Translates to an enumeration including the specified list of cases.
    ///
    /// - Parameter cases: The list of cases in the numeration.
    /// - Returns: An appropriate ``SQLDataType``.
    @inlinable
    public static func `enum`(_ cases: [any SQLExpression]) -> Self {
        self.custom(SQLEnumDataType(cases: cases))
    }
}
