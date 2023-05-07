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

    public func serialize(to serializer: inout SQLSerializer) {
        switch serializer.dialect.enumSyntax {
        case .inline:
            // e.g. ENUM('case1', 'case2')
            SQLRaw("ENUM").serialize(to: &serializer)
            SQLGroupExpression(self.cases).serialize(to: &serializer)
        default:
            // NOTE: Consider using a CHECK constraint
            //      with a TEXT type to verify that the
            //      text value for a column is in a list
            //      of possible options.
            SQLDataType.text.serialize(to: &serializer)
            serializer.database.logger.warning("Database does not support inline enums. Storing as TEXT instead.")
        }
    }
}
