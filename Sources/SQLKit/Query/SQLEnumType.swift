/// `ENUM` type.
///
/// See `SQLDataType`.
public struct SQLEnumType: SQLExpression {
    /// The name of the enum type.
    public var name: SQLExpression

    /// The possible values of the enum type.
    public var values: [SQLExpression]

    /// Creates a new `SQLEnumType`.
    public init(name: SQLExpression, values: [SQLExpression]) {
        self.name = name
        self.values = values
    }

    /// Creates a new `SQLEnumType`.
    public init(name: String, values: [String]) {
        self.init(name: SQLRaw(name), values: values.map { SQLRaw($0) })
    }

    public func serialize(to serializer: inout SQLSerializer) {
        switch serializer.dialect.enumSyntax {
        case .inline(literal: let literal):
            literal.serialize(to: &serializer)
            SQLGroupExpression(values).serialize(to: &serializer)

        case .typeName:
            name.serialize(to: &serializer)

        case .unsupported:
            // NOTE: Consider using a CHECK constraint
            //      with a TEXT type to verify that the
            //      text value for a column is in a list
            //      of possible options.
            fatalError("ENUM types are unsupported by the current dialect.")
        }
    }
}
