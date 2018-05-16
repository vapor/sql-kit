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
        
        /// A single `DataSubqueryColumn`
        case subquery(DataSubqueryColumn, key: String)
    }
    
    /// Internal storage
    let storage: Storage
    
    /// Internal initializer
    init(_ stored: Storage) {
        storage = stored
    }
    
    /// All columns, `*`.
    public static var all = DataQueryColumn(.all)

    /// A single `DataColumn` with optional key.
    public static func column(_ column: DataColumn, key: String? = nil) -> DataQueryColumn {
        return .init(.column(column, key: key))
    }

    /// A single `DataComputedColumn` with optional key.
    public static func computed(_ column: DataComputedColumn, key: String? = nil) -> DataQueryColumn {
        return .init(.computed(column, key: key))
    }
    
    /// A single `DataSubqueryColumn`
    public static func subquery(_ column: DataSubqueryColumn, key: String) -> DataQueryColumn {
        return .init(.subquery(column, key: key))
    }
}
