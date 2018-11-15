/// Table column definition. DDL. Used by `SQLCreateTable` and `SQLAlterTable`.
///
/// See `SQLCreateTableBuilder` and `SQLAlterTableBuilder`.
public protocol SQLColumnDefinition: SQLSerializable {
    /// See `SQLColumnIdentifier`.
    associatedtype ColumnIdentifier: SQLColumnIdentifier
    
    /// See `SQLDataType`.
    associatedtype DataType: SQLDataType
    
    /// See `SQLColumnConstraint`.
    associatedtype ColumnConstraint: SQLColumnConstraint
    
    /// Creates a new `SQLColumnDefinition` from column identifier, data type, and zero or more constraints.
    static func columnDefinition(_ column: ColumnIdentifier, _ dataType: DataType, _ constraints: [ColumnConstraint]) -> Self
}
