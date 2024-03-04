/// An expression representing an `ALTER TYPE` query. Used to add new cases to enumeration types.
///
/// ```sql
/// ALTER TYPE "name" ADD VALUE 'value';
/// ```
///
/// This expression does _not_ check whether the current dialect supports separate enumeration types; users should
/// take care not to use it with incompatible drivers.
///
/// See ``SQLAlterEnumBuilder``.
///
/// > Note: Despite both its name and the query it represents, this expression can neither perform arbitrary enum
/// > alterations, nor represent the full range of possible `ALTER TYPE` queries, even in dialects which support
/// > them in the first place. This would probably have been better named something like `SQLAddEnumCase`.
public struct SQLAlterEnum: SQLExpression {
    /// The name of the type to alter.
    public var name: any SQLExpression
    
    /// A new enumeration value to add to an existing type.
    ///
    /// > Warning: Although this property is optional, setting it to `nil` will result in invalid serialized SQL.
    public var value: (any SQLExpression)?

    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("ALTER TYPE", self.name)
            if let value = self.value {
                $0.append("ADD VALUE", value)
            }
        }
    }
}
