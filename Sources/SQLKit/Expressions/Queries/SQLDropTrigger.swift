/// `DROP TRIGGER` query.
///
/// See ``SQLDropTriggerBuilder``.
public struct SQLDropTrigger: SQLExpression {
    /// Trigger to drop.
    public let name: any SQLExpression

    /// The table the trigger is attached to
    public var table: (any SQLExpression)?

    /// The optional `IF EXISTS` clause suppresses the error that would normally
    /// result if the type does not exist.
    public var ifExists = false

    /// The optional `CASCADE` clause drops other objects that depend on this type
    /// (such as table columns, functions, and operators), and in turn all objects
    /// that depend on those objects.
    public var cascade = false

    /// Creates a new ``SQLDropTrigger``.
    @inlinable
    public init(name: any SQLExpression) {
        self.name = name
    }

    /// See ``SQLExpression/serialize(to:)``.
    public func serialize(to serializer: inout SQLSerializer) {
        let dialect = serializer.dialect
        let triggerDropSyntax = dialect.triggerSyntax.drop

        serializer.statement {
            $0.append("DROP TRIGGER")
            if self.ifExists && dialect.supportsIfExists {
                $0.append("IF EXISTS")
            }
            $0.append(self.name)
            if let table = self.table, triggerDropSyntax.contains(.supportsTableName) {
                $0.append("ON", table)
            }
            if self.cascade && triggerDropSyntax.contains(.supportsCascade) {
                $0.append("CASCADE")
            }
        }
    }
}
