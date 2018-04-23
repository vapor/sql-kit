/// A single foreign key, referencing two columns.
public struct DataDefinitionForeignKey {
    /// This foreign key's unique name.
    public var name: String

    /// The local column being referenced.
    public var local: DataColumn

    /// The foreign column being referenced.
    public var foreign: DataColumn

    /// An optional `DataDefinitionForeignKeyAction` to apply on updates.
    public var onUpdate: DataDefinitionForeignKeyAction?

    /// An optional `DataDefinitionForeignKeyAction` to apply on delete.
    public var onDelete: DataDefinitionForeignKeyAction?

    public init(
        name: String,
        local: DataColumn,
        foreign: DataColumn,
        onUpdate: DataDefinitionForeignKeyAction? = nil,
        onDelete: DataDefinitionForeignKeyAction? = nil
    ) {
        self.name = name
        self.local = local
        self.foreign = foreign
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }
}
