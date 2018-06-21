public protocol SQLForeignKey: SQLSerializable {
    associatedtype TableIdentifier: SQLTableIdentifier
    associatedtype Identifier: SQLIdentifier
    associatedtype Action: SQLForeignKeyAction
    
    static func foreignKey(
        _ foreignTable: TableIdentifier,
        _ foreignColumns: [Identifier],
        onDelete: Action?,
        onUpdate: Action?
    ) -> Self
}

// MARK: Generic

public struct GenericSQLForeignKey<TableIdentifier, Identifier, Action>: SQLForeignKey
    where TableIdentifier: SQLTableIdentifier, Identifier: SQLIdentifier, Action: SQLForeignKeyAction
{
    public typealias `Self` = GenericSQLForeignKey<TableIdentifier, Identifier, Action>
    
    /// See `SQLForeignKey`.
    public static func foreignKey(
        _ foreignTable: TableIdentifier,
        _ foreignColumns: [Identifier],
        onDelete: Action?,
        onUpdate: Action?
    ) -> Self {
        return .init(foreignTable: foreignTable, foreignColumns: foreignColumns, onDelete: onDelete, onUpdate: onUpdate)
    }
    
    public var foreignTable: TableIdentifier
    
    public var foreignColumns: [Identifier]
    
    public var onDelete: Action?
    
    public var onUpdate: Action?
    
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
