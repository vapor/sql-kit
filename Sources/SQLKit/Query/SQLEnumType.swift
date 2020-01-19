/// `ENUM` type.
///
/// See `SQLDataType`.
public protocol SQLEnumType: SQLExpressibleType {
    /// The name of the enum type.
    static var sqlTypeName: SQLExpression { get }

    /// The possible values of the enum type.
    ///
    /// Commonly implemented as a `SQLGroupExpression`
    static var sqlEnumCases: SQLExpression { get }
}

extension CaseIterable where Self: RawRepresentable, Self.RawValue == String {
    public static var sqlEnumCases: SQLExpression {
        return SQLGroupExpression(Self.allCases.map { SQLLiteral.string($0.rawValue) })
    }
}

extension SQLEnumType {
    public static var sqlExpression: SQLExpression {
        return SQLEnum(name: Self.sqlTypeName, sqlEnumCases: Self.sqlEnumCases)
    }
}

internal struct SQLEnum: SQLExpression {
    /// The name of the enum type.
    var name: SQLExpression

    /// The possible values of the enum type.
    ///
    /// Commonly implemented as a `SQLGroupExpression`
    var sqlEnumCases: SQLExpression

    public func serialize(to serializer: inout SQLSerializer) {
        switch serializer.dialect.enumSyntax {
        case .inline:
            // e.g. ENUM('case1', 'case2')
            name.serialize(to: &serializer)
            sqlEnumCases.serialize(to: &serializer)

        case .typeName:
            // e.g. WEEKDAY (can be whatever name the user creates a type for)
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
