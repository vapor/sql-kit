/// Supported column types in a `DataQuery`.
public struct DataQueryColumn {
    
    /// Internal storage
    enum Storage {
        /// All columns, `*`.
        case all
        
        /// A single `DataColumn` with optional key.
        case column(DataColumn, key: String?)
        
        /// A single `DataComputedColumn` with optional key.
        case computed(DataComputedColumn, key: String?)
    }
    
    /// Internal storage
    let storage: Storage
    
    /// Internal initializer
    init(stored: Storage) {
        storage = stored
    }
    
    /// All columns, `*`.
    public static var all = DataQueryColumn(stored: .all)

    /// A single `DataColumn` with optional key.
    public static func column(_ column: DataColumn, key: String? = nil) -> DataQueryColumn {
        return .column(column, key: key)
    }

    /// A single `DataComputedColumn` with optional key.
    public static func computed(_ column: DataComputedColumn, key: String? = nil) -> DataQueryColumn {
        return .computed(column, key: key)
    }
}
