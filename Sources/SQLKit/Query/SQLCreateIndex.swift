/// `CREATE INDEX` query.
///
/// See `SQLCreateIndexBuilder`.
public protocol SQLCreateIndex: SQLSerializable {
    /// See `SQLIndexModifier`.
    associatedtype Modifier: SQLIndexModifier
    
    /// See `SQLIdentifier`.
    associatedtype Identifier: SQLIdentifier
    
    /// See `SQLColumnIdentifier`.
    associatedtype ColumnIdentifier: SQLColumnIdentifier
    
    /// Creates a new `SQLCreateIndex.
    static func createIndex(name: Identifier) -> Self
    
    /// Type of index to create, see `SQLIndexModifier`.
    var modifier: Modifier? { get set }
    
    /// Columns to index.
    var columns: [ColumnIdentifier] { get set }
}
