/// All supported values for a SQL `DataPredicate`.
public enum DataManipulationValue {
    /// One or more placeholders.
    case values([Encodable])

    /// A single placeholder.
    public static func value(_ encodable: Encodable) -> DataManipulationValue {
        return .values([encodable])
    }

    /// Compare to another column in the database.
    case column(DataColumn)

    /// Compare to a computed column.
    case computed(DataComputedColumn)

    /// Serializes a complete sub-query as this predicate's value.
    case subquery(DataManipulationQuery)

    /// NULL value.
    case null

    /// Custom string that will be interpolated into the SQL query.
    /// - warning: Be careful about SQL injection when using this.
    case custom(unescaped: String)
}
