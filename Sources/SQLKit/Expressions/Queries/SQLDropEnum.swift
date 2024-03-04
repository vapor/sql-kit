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
    public let name: any SQLExpression

    /// If `true`, requests idempotent behavior (e.g. that no error be raised if the named type does not exist).
    ///
    /// Ignored if not supported by the dialect.
    public var ifExists: Bool

    /// The optional `CASCADE` clause drops other objects that depend on this type
    /// (such as table columns, functions, and operators), and in turn all objects
    /// that depend on those objects.
    public var cascade: Bool

    /// Create a new enumeration deletion query.
    ///
    /// - Parameter name: The name of the enumeration to delete.
    @inlinable
    public init(name: any SQLExpression) {
        self.name = name
        self.ifExists = false
        self.cascade = false
    }

    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("DROP TYPE")
            if self.ifExists {
                $0.append("IF EXISTS")
            }
            $0.append(self.name)
            if self.cascade {
                $0.append("CASCADE")
            }
        }
    }
}
