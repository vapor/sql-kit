public protocol SQLForeignKey: SQLSerializable {
    associatedtype TableIdentifier: SQLTableIdentifier
    associatedtype Identifier: SQLIdentifier
    associatedtype ConflictResolution: SQLConflictResolution
    
    static func foreignKey(
        _ foreignTable: TableIdentifier,
        _ foreignColumns: [Identifier],
        onDelete: ConflictResolution?,
        onUpdate: ConflictResolution?
    ) -> Self
}

// MARK: Generic

public struct GenericSQLForeignKey<TableIdentifier, Identifier, ConflictResolution>: SQLForeignKey
    where TableIdentifier: SQLTableIdentifier, Identifier: SQLIdentifier, ConflictResolution: SQLConflictResolution
{
    public typealias `Self` = GenericSQLForeignKey<TableIdentifier, Identifier, ConflictResolution>
    
    /// See `SQLForeignKey`.
    public static func foreignKey(
        _ foreignTable: TableIdentifier,
        _ foreignColumns: [Identifier],
        onDelete: ConflictResolution?,
        onUpdate: ConflictResolution?
    ) -> Self {
        return .init(foreignTable: foreignTable, foreignColumns: foreignColumns, onDelete: onDelete, onUpdate: onUpdate)
    }
    
    public var foreignTable: TableIdentifier
    
    public var foreignColumns: [Identifier]
    
    public var onDelete: ConflictResolution?
    
    public var onUpdate: ConflictResolution?
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append(foreignTable.serialize(&binds))
        sql.append("(" + foreignColumns.serialize(&binds) + ")")
        if let onDelete = onDelete {
            sql.append("ON DELETE")
            sql.append(onDelete.serialize(&binds))
        }
        if let onUpdate = onUpdate {
            sql.append("ON UPDATE")
            sql.append(onUpdate.serialize(&binds))
        }
        return sql.joined(separator: " ")
    }
}
