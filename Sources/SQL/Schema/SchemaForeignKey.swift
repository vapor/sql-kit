/// A single foreign key, referencing two columns.
public struct SchemaForeignKey {
    /// This foreign key's unique name.
    public var name: String

    /// The local column being referenced.
    public var local: DataColumn

    /// The foreign column being referenced.
    public var foreign: DataColumn

    /// An optional `SchemaForeignKeyAction` to apply on updates.
    public var onUpdate: SchemaForeignKeyAction?

    /// An optional `SchemaForeignKeyAction` to apply on delete.
    public var onDelete: SchemaForeignKeyAction?

    public init(name: String, local: DataColumn, foreign: DataColumn, onUpdate: SchemaForeignKeyAction? = nil, onDelete: SchemaForeignKeyAction? = nil) {
        self.name = name
        self.local = local
        self.foreign = foreign
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }
}
