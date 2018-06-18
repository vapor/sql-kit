public protocol SQLAlterTable: SQLSerializable {
    associatedtype TableIdentifier: SQLTableIdentifier

    static func alterTable(_ table: TableIdentifier) -> Self
}

// No generic ALTER table is offered since they differ too much
// between SQL dialects
