/// Available methods for `GROUP BY`, either column or custom.
public enum DataGroupBy {
    /// Group by a particular column.
    case column(DataColumn)

    /// Group by a computed column.
    case computed(DataComputedColumn)
}
