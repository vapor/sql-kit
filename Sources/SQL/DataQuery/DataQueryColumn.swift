/// Supported column types in a `DataQuery`.
public enum DataQueryColumn {
    /// All columns, `*`.
    case all
    
    /// All columns of a table, `foo`.*
    case tableAll(table: String)

    /// A single `DataColumn` with optional key.
    case column(DataColumn, key: String?)

    /// A single `DataComputedColumn` with optional key.
    case computed(DataComputedColumn, key: String?)
}
