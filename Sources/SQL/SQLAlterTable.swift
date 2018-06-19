public protocol SQLAlterTable: SQLSerializable {
    associatedtype TableIdentifier: SQLTableIdentifier
    associatedtype ColumnDefinition: SQLColumnDefinition

    static func alterTable(_ table: TableIdentifier) -> Self
    
    var columns: [ColumnDefinition] { get set }
}

// No generic ALTER table is offered since they differ too much
// between SQL dialects
