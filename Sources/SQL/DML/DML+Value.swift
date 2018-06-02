extension SQLQuery.DML {
    /// All supported values for a SQL `DataPredicate`.
    public struct Value {
        /// A single placeholder.
        public static func bind(_ encodable: Encodable) -> Value {
            return .binds([encodable])
        }
        
        public static func column(_ column: Column) -> Value {
            return self.init(storage: .column(column))
        }
        
        /// One or more placeholders.
        public static func binds(_ encodables: [Encodable]) -> Value {
            return self.init(storage: .binds(encodables))
        }
        
        public static var null: Value {
            return self.init(storage: .null)
        }
        
        public static func unescaped(_ sql: String) -> Value {
            return self.init(storage: .unescaped(sql))
        }
        
        /// Internal storage type.
        /// - warning: Enum cases are subject to change.
        public enum Storage {
            /// One or more placeholders.
            case binds([Encodable])
            /// Compare to another column in the database.
            case column(Column)
            /// Compare to a computed column.
            case computed(ComputedColumn)
            /// Serializes a complete sub-query as this predicate's value.
            case subquery(SQLQuery.DML)
            /// NULL value.
            case null
            /// Custom string that will be interpolated into the SQL query.
            /// - warning: Be careful about SQL injection when using this.
            case unescaped(String)
        }
        
        /// Internal storage.
        /// - warning: Enum cases are subject to change.
        public let storage: Storage
    }
}
