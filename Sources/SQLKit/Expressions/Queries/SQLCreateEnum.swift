/// An expression representing a `CREATE TYPE` query. Used to create enumeration types.
/// 
/// ```sql
/// CREATE TYPE "name" AS ENUM ('value1', 'value2');
/// ```
/// 
/// This expression does _not_ check whether the current dialect supports separate enumeration types; users should
/// take care not to use it with incompatible drivers.
/// 
/// > Note: As with ``SQLAlterEnum``, the full range of the `CREATE TYPE` query is not supported by this expression.
/// 
/// See ``SQLCreateEnumBuilder``.
public struct SQLCreateEnum: SQLExpression {
    /// The name for the created type.
    public var name: any SQLExpression

    /// The enumeration values for the new type.
    ///
    /// Must contain at least one value.
    public var values: [any SQLExpression]

    /// Create a type creation query for the given name and value list.
    ///
    /// - Parameters:
    ///   - name: The name of the new type.
    ///   - values: One or more enumeration values associated with the new type.
    @inlinable
    public init(name: any SQLExpression, values: [any SQLExpression]) {
        self.name = name
        self.values = values
    }

    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("CREATE TYPE", self.name)
            $0.append("AS ENUM", SQLGroupExpression(self.values))
        }
    }
}
