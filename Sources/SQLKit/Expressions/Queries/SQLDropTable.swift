/// An expression representing a `DROP TABLE` query. Used to delete entire tables.
/// 
/// ```sql
/// DROP TEMPORARY TABLE IF EXISTS "table" CASCADE;
/// ```
/// 
/// See ``SQLDropTableBuilder``.
public struct SQLDropTable: SQLExpression {
    /// The table to drop.
    public var table: any SQLExpression
    
    /// If `true`, requests idempotent behavior (e.g. that no error be raised if the named table does not exist).
    ///
    /// Ignored if not supported by the dialect.
    public var ifExists: Bool

    /// A drop behavior.
    ///
    /// Ignored if not supported by the dialect. See ``SQLDropBehavior``.
    public var behavior: (any SQLExpression)?

    /// If `true`, requests that an error be raised if the named table exists but is not temporary.
    ///
    /// This modifier is only supported by MySQL, and there is no check for it; users must be sure to only use it
    /// where available.
    public var temporary: Bool

    /// Create a new table deletion query.
    ///
    /// - Parameter table: The name of the table to drop.
    @inlinable
    public init(table: any SQLExpression) {
        self.table = table
        self.ifExists = false
        self.behavior = nil
        self.temporary = false
    }
    
    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("DROP")
            if self.temporary {
                $0.append("TEMPORARY")
            }
            $0.append("TABLE")
            if self.ifExists, $0.dialect.supportsIfExists {
                $0.append("IF EXISTS")
            }
            $0.append(self.table)
            if $0.dialect.supportsDropBehavior {
                $0.append(self.behavior)
            }
        }
    }
}
