/// Supported column types in a `DataQuery`.
public enum DataManipulationKey {
    /// All columns, `*`., or all columns of a table, `foo`.*
    case all(table: String?)

    /// A single `DataColumn` with optional key.
    case column(DataColumn, key: String?)

    /// A single `DataComputedColumn` with optional key.
    case computed(DataComputedColumn, key: String?)
}
