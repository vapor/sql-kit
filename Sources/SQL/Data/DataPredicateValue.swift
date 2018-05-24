/// All supported values for a SQL `DataPredicate`.
public enum DataManipulationValue {
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

    /// One or more placeholders.
    case binds([Encodable])

    /// A single placeholder.
    public static func bind(_ encodable: Encodable) -> DataManipulationValue {
        return .binds([encodable])
    }
}
