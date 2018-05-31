extension Query.DML {
    /// A SQL `ORDER BY` that determines the order of results.
    public struct OrderBy {
        public static func ascending(_ columns: [Column]) -> OrderBy {
            return .init(columns: columns, direction: .ascending)
        }
        
        public static func descending(_ columns: [Column]) -> OrderBy {
            return .init(columns: columns, direction: .descending)
        }
        
        /// Available order by directions for a `DataOrderBy`.
        public enum Direction {
            /// DESC
            case ascending
            
            /// ASC
            case descending
        }
        
        /// The columns to order.
        public var columns: [Column]
        
        /// The direction to order the results.
        public var direction: Direction
        
        /// Creates a new SQL `DataOrderBy`
        public init(columns: [Column], direction: Direction) {
            self.columns = columns
            self.direction = direction
        }
    }
}
