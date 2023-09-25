/// `DROP TABLE` query.
///
/// See ``SQLDropTableBuilder``.
public struct SQLDropTable: SQLExpression {
    /// Table to drop.
    public let table: any SQLExpression
    
    /// The optional `IF EXISTS` clause suppresses the error that would normally
    /// result if the table does not exist.
    public var ifExists: Bool

    /// The optional drop behavior clause specifies if objects that depend on the
    /// table should also be dropped or not, for databases that support this
    /// (either `CASCADE` or `RESTRICT`).
    public var behavior: (any SQLExpression)?

    /// If the "TEMPORARY" keyword occurs between "DROP" and "TABLE" then only temporary tables are dropped,
    /// and the drop does not cause an implicit transaction commit.
    public var temporary: Bool

    /// Creates a new ``SQLDropTable``.
    @inlinable
    public init(table: any SQLExpression) {
        self.table = table
        self.ifExists = false
        self.behavior = nil
        self.temporary = false
    }
    
    /// See ``SQLExpression/serialize(to:)``.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("DROP")
            if self.temporary { // TODO: Add `SQLDialect` field to signal support for this, only MySQL has it
                $0.append("TEMPORARY")
            }
            $0.append("TABLE")
            if self.ifExists {
                if $0.dialect.supportsIfExists {
                    $0.append("IF EXISTS")
                } else {
                    $0.database.logger.warning("\($0.dialect.name) does not support IF EXISTS")
                }
            }
            $0.append(self.table)
            if $0.dialect.supportsDropBehavior {
                $0.append(self.behavior ?? (SQLDropBehavior.restrict as any SQLExpression))
            }
        }
    }
}
