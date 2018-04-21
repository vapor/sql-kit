/// Supported `SchemaQuery` action types.
public enum SchemaStatement {
    /// `CREATE` a table. Define a table, adding columns.
    case create

    /// `ALTER` a table. Add or remove columns.
    case alter

    /// `DROP` a table. Removes all columns (and data).
    case drop
}
