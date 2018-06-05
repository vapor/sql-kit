extension SQLQuery.DML {
    /// A computed SQL column.
    public struct ComputedColumn {
        /// Creates a new SQL `DataComputedColumn`.
        public static func function(_ function: String, _ keys: Key...) -> ComputedColumn {
            return .init(function: function, keys: keys)
        }
        
        /// Creates a new SQL `DataComputedColumn`.
        public static func function(_ function: String) -> ComputedColumn {
            return .init(function: function, keys: [])
        }
        
        /// The SQL function to call.
        public var function: String
        
        /// The SQL data column parameters to the function. Can be none.
        public var keys: [Key]
        
        /// Creates a new SQL `DataComputedColumn`.
        public init(function: String, keys: [Key] = []) {
            self.function = function
            self.keys = keys
        }
    }
}
