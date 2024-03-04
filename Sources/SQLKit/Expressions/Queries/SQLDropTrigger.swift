/// An expression representing a `DROP TRIGGER` query. Used to delete triggers.
///
/// ```sql
/// DROP TRIGGER IF EXISTS "name" ON "table" CASCADE;
/// ```
///
/// See ``SQLDropTriggerBuilder``.
public struct SQLDropTrigger: SQLExpression {
    /// The name of the trigger to drop.
    public var name: any SQLExpression

    /// The table to which the trigger is attached.
    ///
    /// This value is ignored if the dialect does not support its use.
    public var table: (any SQLExpression)?

    /// If `true`, requests idempotent behavior (e.g. that no error be raised if the named trigger does not exist).
    ///
    /// Ignored if not supported by the dialect.
    public var ifExists = false

    /// A drop behavior.
    ///
    /// Ignored if not supported by the dialect. See ``SQLDropBehavior``.
    public var dropBehavior = SQLDropBehavior.restrict

    /// Create a new trigger deletion query.
    ///
    /// - Parameter name: The name of the trigger to drop.
    @inlinable
    public init(name: any SQLExpression) {
        self.name = name
    }

    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        let dialect = serializer.dialect
        
        serializer.statement {
            $0.append("DROP TRIGGER")
            if self.ifExists && dialect.supportsIfExists {
                $0.append("IF EXISTS")
            }
            $0.append(self.name)
            if let table = self.table, dialect.triggerSyntax.drop.contains(.supportsTableName) {
                $0.append("ON", table)
            }
            if dialect.triggerSyntax.drop.contains(.supportsCascade) {
                $0.append(self.dropBehavior)
            }
        }
    }
}
