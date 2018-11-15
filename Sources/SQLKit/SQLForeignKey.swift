/// `FOREIGN KEY` clause.
public protocol SQLForeignKey: SQLSerializable {
    /// See `SQLIdentifier`.
    associatedtype Identifier: SQLIdentifier
    
    /// See `SQLForeignKeyAction`.
    associatedtype ForeignKeyAction: SQLForeignKeyAction
    
    /// Creates a new `SQLForeignKey`.
    static func foreignKey(
        table: Identifier,
        columns: [Identifier],
        onDelete: ForeignKeyAction?,
        onUpdate: ForeignKeyAction?
    ) -> Self
}

// MARK: Generic

///// Generic implementation of `SQLForeignKey`.
//public struct GenericSQLForeignKey<TableIdentifier, Identifier, Action>: SQLForeignKey
//    where TableIdentifier: SQLTableIdentifier, Identifier: SQLIdentifier, Action: SQLForeignKeyAction
//{
//    /// Convenience alias for self.
//    public typealias `Self` = GenericSQLForeignKey<TableIdentifier, Identifier, Action>
//    
//    /// See `SQLForeignKey`.
//    public static func foreignKey(
//        _ foreignTable: TableIdentifier,
//        _ foreignColumns: [Identifier],
//        onDelete: Action?,
//        onUpdate: Action?
//    ) -> Self {
//        return .init(foreignTable: foreignTable, foreignColumns: foreignColumns, onDelete: onDelete, onUpdate: onUpdate)
//    }
//    
//    /// See `SQLForeignKey`.
//    public var foreignTable: TableIdentifier
//    
//    /// See `SQLForeignKey`.
//    public var foreignColumns: [Identifier]
//    
//    /// See `SQLForeignKey`.
//    public var onDelete: Action?
//    
//    /// See `SQLForeignKey`.
//    public var onUpdate: Action?
//    
//    /// See `SQLSerializable`.
//    public func serialize(_ binds: inout [Encodable]) -> String {
//        var sql: [String] = []
//        sql.append(foreignTable.serialize(&binds))
//        sql.append("(" + foreignColumns.serialize(&binds) + ")")
//        if let onDelete = onDelete {
//            sql.append("ON DELETE")
//            sql.append(onDelete.serialize(&binds))
//        }
//        if let onUpdate = onUpdate {
//            sql.append("ON UPDATE")
//            sql.append(onUpdate.serialize(&binds))
//        }
//        return sql.joined(separator: " ")
//    }
//}
