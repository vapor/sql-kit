extension SQLDataType {
    @inlinable
    public static func `enum`(_ cases: String...) -> Self {
        self.enum(cases)
    }

    @inlinable
    public static func `enum`(_ cases: [String]) -> Self {
        self.enum(cases.map { SQLLiteral.string($0) })
    }
    @inlinable
    public static func `enum`(_ cases: [any SQLExpression]) -> Self {
        self.custom(SQLEnumDataType(cases: cases))
    }
}

public struct SQLEnumDataType: SQLExpression {
    /// The possible values of the enum type.
    ///
    /// Commonly implemented as a ``SQLGroupExpression``.
    @usableFromInline
    var cases: [any SQLExpression]

    @inlinable
    public init(cases: [String]) {
        self.init(cases: cases.map { SQLLiteral.string($0) })
    }

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
