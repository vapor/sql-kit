/// Supported `DataDefinitionQuery` action types.
public enum DataDefinitionStatement {
    /// `CREATE` a table. Define a table, adding columns.
    case create

    /// `ALTER` a table. Add or remove columns.
    case alter

    /// `DROP` a table. Removes all columns (and data).
    case drop

    /// `TRUNCATE` a table. Removes all data.
    case truncate
}
