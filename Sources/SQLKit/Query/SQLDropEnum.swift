/// `DROP TYPE` query.
///
/// See ``SQLDropEnumBuilder``.
public struct SQLDropEnum: SQLExpression {
    /// Type to drop.
    public let name: any SQLExpression

    /// The optional `IF EXISTS` clause suppresses the error that would normally
    /// result if the type does not exist.
    public var ifExists: Bool

    /// The optional `CASCADE` clause drops other objects that depend on this type
    /// (such as table columns, functions, and operators), and in turn all objects
    /// that depend on those objects.
    public var cascade: Bool

    /// Creates a new `SQLDropEnum`.
    @inlinable
    public init(name: any SQLExpression) {
        self.name = name
        self.ifExists = false
        self.cascade = false
    }

    /// See `SQLExpression`.
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
