/// A builder used to construct a `SELECT` query for use as part of a `CREATE TABLE` query.
///
/// - Note: There's really nothing for this builder to do besides provide a concrete storage
///   for the `select` property of ``SQLSubqueryClauseBuilder``. All of the interesting methods
///   are on the protocol.
public final class SQLCreateTableAsSubqueryBuilder: SQLSubqueryClauseBuilder {
    // See `SQLSubqueryClauseBuilder.select`.
    public var select: SQLSelect
    
    /// Create a new `SQLCreateTableAsSubqueryBuilder`.
    @usableFromInline
    internal init() {
        self.select = .init()
    }
}
