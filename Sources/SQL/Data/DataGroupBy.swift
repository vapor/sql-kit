/// Available methods for `GROUP BY`, either column or custom.
public enum DataGroupBy {
    /// Group by a particular column.
    case column(DataColumn)

    /// Group by an arbitrary string.
    /// - warning: Be careful about SQL injection when using this.
    case custom(String)
}
