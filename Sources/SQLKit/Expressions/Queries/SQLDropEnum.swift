/// An expression representing a `DROP TYPE` query. Used to delete enumeration types.
///
/// ```sql
/// DROP TYPE IF EXISTS "enum_type" CASCADE:
/// ```
/// 
/// This expression does _not_ check whether the current dialect supports separate enumeration types; users should
/// take care not to use it with incompatible drivers.
/// 
/// See ``SQLDropEnumBuilder``.
public struct SQLDropEnum: SQLExpression {
    /// The name of the type to drop.
    public var name: any SQLExpression

    /// If `true`, requests idempotent behavior (e.g. that no error be raised if the named type does not exist).
    ///
    /// Ignored if not supported by the dialect.
    public var ifExists: Bool

    /// A drop behavior.
    ///
    /// Ignored if not supported by the dialect. See ``SQLDropBehavior``.
    public var dropBehavior: SQLDropBehavior

    /// Create a new enumeration deletion query.
    ///
    /// - Parameter name: The name of the enumeration to delete.
    @inlinable
    public init(name: any SQLExpression) {
        self.name = name
        self.ifExists = false
        self.dropBehavior = .restrict
    }

    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("DROP TYPE")
            if self.ifExists, $0.dialect.supportsIfExists {
                $0.append("IF EXISTS")
            }
            $0.append(self.name, self.dropBehavior)
        }
    }
}
