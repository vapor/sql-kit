/// `DROP TYPE` query.
///
/// See `SQLDropTriggerBuilder`.
public struct SQLDropTrigger: SQLExpression {
    /// Trigger to drop.
    public let name: SQLExpression

    /// The table the trigger is attached to
    public let table: SQLExpression

    /// The optional `IF EXISTS` clause suppresses the error that would normally
    /// result if the type does not exist.
    public var ifExists: Bool

    /// The optional `CASCADE` clause drops other objects that depend on this type
    /// (such as table columns, functions, and operators), and in turn all objects
    /// that depend on those objects.
    public var cascade: Bool

    /// Creates a new `SQLDropTrigger`
    public init(name: SQLExpression, table: SQLExpression, ifExists: Bool = false, cascade: Bool = false) {
        self.name = name
        self.table = table
        self.ifExists = ifExists
        self.cascade = cascade
    }

    /// See `SQLExpression`
    public func serialize(to serializer: inout SQLSerializer) {
        let dialect = serializer.dialect

        serializer.statement {
            $0.append("DROP TRIGGER")

            if self.ifExists && dialect.supportsIfExists {
                $0.append("IF EXISTS")
            }

            $0.append(self.name)

            if dialect.supportsDropTriggerTable {
                $0.append("ON")
                $0.append(self.table)
            }

            if self.cascade && dialect.supportsDropTriggerCascade {
                $0.append("CASCADE")
            }
        }
    }
}
