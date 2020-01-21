extension SQLDataType {
    public static func `enum`(_ cases: String...) -> Self {
        self.enum(cases)
    }

    public static func `enum`(_ cases: [String]) -> Self {
        self.enum(cases.map { SQLLiteral.string($0) })
    }
    public static func `enum`(_ cases: [SQLExpression]) -> Self {
        self.custom(SQLEnumDataType(cases: cases))
    }
}

public struct SQLEnumDataType: SQLExpression {
    /// The possible values of the enum type.
    ///
    /// Commonly implemented as a `SQLGroupExpression`
    var cases: [SQLExpression]

    public init(cases: [String]) {
        self.cases = cases.map { SQLLiteral.string($0) }
    }

    public init(cases: [SQLExpression]) {
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
