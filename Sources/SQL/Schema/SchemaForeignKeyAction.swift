/// Foreign key actions to apply when data related via a
/// foreign key is updated or deleted.
public enum SchemaForeignKeyAction {
    /// Do nothing.
    case noAction

    /// Restrict the operation, this is the default.
    case restrict

    /// Set the relation to null.
    case setNull

    /// Set the relation to default values.
    case setDefault

    /// Cascade the operation. For example, if an entity is deleted
    /// then also delete the related entity.
    case cascade
}
