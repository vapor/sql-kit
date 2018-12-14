/// `DROP TABLE` query.
///
/// See `SQLDropTableBuilder`.
public protocol SQLDropTable: SQLSerializable {
    /// See `SQLTableIdentifier`.
    associatedtype Identifier: SQLIdentifier
    
    /// Creates a new `SQLDropTable`.
    static func dropTable(name table: Identifier) -> Self
    
    /// Table to drop.
    var table: Identifier { get set }
    
    /// The optional `IF EXISTS` clause suppresses the error that would normally
    /// result if the table does not exist.
    var ifExists: Bool { get set }
}
