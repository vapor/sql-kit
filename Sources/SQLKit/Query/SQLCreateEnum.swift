/// The `CREATE TYPE` command is used to create a new types in a database.
///
/// See ``SQLCreateEnumBuilder``.
public struct SQLCreateEnum: SQLExpression {
    /// Name of type to create.
    public var name: any SQLExpression

    public var values: [any SQLExpression]

    @inlinable
    public init(name: any SQLExpression, values: [any SQLExpression]) {
        self.name = name
        self.values = values
    }

    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("CREATE TYPE")
            $0.append(self.name)
            $0.append("AS ENUM")
            $0.append(SQLGroupExpression(self.values))
        }
    }
}
