/// All supported values for a SQL `DataManipulationValue`.
public enum DataManipulationValue {
    /// A value placeholder.
    case placeholder

    /// Compare to another column in the database.
    case column(DataColumn)

    /// Compare to a computed column.
    case computed(DataComputedColumn)

    /// Serializes a complete sub-query as this predicate's value.
    case subquery(DataQuery)

    /// Custom string that will be interpolated into the SQL query.
    /// - warning: Be careful about SQL injection when using this.
    case custom(sql: String)
}
