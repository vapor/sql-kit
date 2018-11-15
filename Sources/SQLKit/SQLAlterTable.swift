/// `ALTER TABLE` query.
///
///     conn.alter(table: Planet.self)
///         .column(for: \.name)
///         .run()
///
/// See `SQLAlterTableBuilder` for more information.
public protocol SQLAlterTable: SQLSerializable {
    /// See `SQLTableIdentifier`.
    associatedtype TableIdentifier: SQLTableIdentifier
    
    /// See `SQLColumnDefinition`.
    associatedtype ColumnDefinition: SQLColumnDefinition

    /// Creates a new `SQLAlterTable`. See `SQLAlterTableBuilder`.
    ///
    /// - parameters:
    ///     - table: Table to alter.
    static func alterTable(_ table: TableIdentifier) -> Self
    
    /// Columns to add.
    var columns: [ColumnDefinition] { get set }
}
