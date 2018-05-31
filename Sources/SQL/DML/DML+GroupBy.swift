extension DML {
    /// Represents a SQL `GROUP BY`. One or more can be added to a `DML` query.
    public struct GroupBy {
        /// Creates a new `Column` based `GroupBy`.
        ///
        ///     .computed("name") // GROUP BY name
        ///
        /// - parameters:
        ///     - computed: `ComputedColumn` to use for `GroupBy`.
        /// - returns: Newly created `GroupBy`.
        public static func column(_ column: Column) -> GroupBy {
            return .init(storage: .column(column))
        }
        
        /// Creates a new `ComputedColumn` based `GroupBy`.
        ///
        ///     .computed(.function("count", .all)) // GROUP BY count(*)
        ///
        /// - parameters:
        ///     - computed: `ComputedColumn` to use for `GroupBy`.
        /// - returns: Newly created `GroupBy`.
        public static func computed(_ computed: ComputedColumn) -> GroupBy {
            return .init(storage: .computed(computed))
        }
        
        /// Internal storage type.
        /// - warning: Enum cases are subject to change.
        public enum Storage {
            /// Group by a particular column.
            case column(Column)
            /// Group by a computed column.
            case computed(ComputedColumn)
        }
        
        /// Internal storage.
        /// - warning: Enum cases are subject to change.
        public let storage: Storage
    }
}
