/// `ALTER TABLE` query.
///
///     conn.alter(table: Planet.self)
///         .column(for: \.name)
///         .run()
///
/// See `SQLAlterTableBuilder` for more information.
public protocol SQLAlterTable: SQLSerializable {
    /// See `SQLTableIdentifier`.
    associatedtype Identifier: SQLIdentifier
    
    /// See `SQLColumnDefinition`.
    associatedtype ColumnDefinition: SQLColumnDefinition

    /// Creates a new `SQLAlterTable`. See `SQLAlterTableBuilder`.
    ///
    /// - parameters:
    ///     - table: Table to alter.
    static func alterTable(name: Identifier) -> Self
    
    /// Columns to add.
    var columns: [ColumnDefinition] { get set }
}
