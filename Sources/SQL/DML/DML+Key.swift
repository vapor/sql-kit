extension SQLQuery.DML {
    /// Supported column types in a `DataQuery`.
    public struct Key: ExpressibleByStringLiteral {
        /// All columns, `*`., or all columns of a table, `foo`.*
        public static func all(table: String?) -> Key {
            return .init(storage: .all(table: table))
        }
        
        /// All columns, `*`., or all columns of a table, `foo`.*
        public static var all: Key {
            return .init(storage: .all(table: nil))
        }
        
        /// A single `DataColumn` with optional key.
        public static func column(_ column: Column, as key: String? = nil) -> Key {
            return .init(storage: .column(column, key: key))
        }
        
        /// A single `DataComputedColumn` with optional key.
        public static func computed(_ computed: ComputedColumn, as key: String? = nil) -> Key {
            return .init(storage: .computed(computed, key: key))
        }
        
        /// Internal storage.
        enum Storage {
            /// All columns, `*`., or all columns of a table, `foo`.*
            case all(table: String?)
            
            /// A single `DataColumn` with optional key.
            case column(Column, key: String?)
            
            /// A single `DataComputedColumn` with optional key.
            case computed(ComputedColumn, key: String?)
        }
        
        /// Internal storage.
        let storage: Storage
        
        /// Creates a new `Key`.
        init(storage: Storage) {
            self.storage = storage
        }
        
        /// See `ExpressibleByStringLiteral`.
        public init(stringLiteral value: String) {
            self = .column(.init(stringLiteral: value))
        }
    }
}
