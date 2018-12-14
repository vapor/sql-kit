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
