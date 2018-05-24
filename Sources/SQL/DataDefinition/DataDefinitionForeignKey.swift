/// A single foreign key, referencing two columns.
public struct DataDefinitionForeignKey {
    /// The local column being referenced.
    public var local: DataColumn

    /// The foreign column being referenced.
    public var foreign: DataColumn

    /// An optional `DataDefinitionForeignKeyAction` to apply on updates.
    public var onUpdate: DataDefinitionForeignKeyAction?

    /// An optional `DataDefinitionForeignKeyAction` to apply on delete.
    public var onDelete: DataDefinitionForeignKeyAction?

    /// Creates a new `DataDefinitionForeignKey`.
    public init(
        local: DataColumn,
        foreign: DataColumn,
        onUpdate: DataDefinitionForeignKeyAction? = nil,
        onDelete: DataDefinitionForeignKeyAction? = nil
    ) {
        self.local = local
        self.foreign = foreign
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }
}
