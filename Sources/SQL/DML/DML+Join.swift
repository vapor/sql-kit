extension SQLQuery.DML {
    /// Represents a SQL join.
    public struct Join {
        /// Supported SQL `DataJoin` methods.
        public enum Method {
            /// (INNER) JOIN: Returns records that have matching values in both tables
            case inner
            /// LEFT (OUTER) JOIN: Return all records from the left table, and the matched records from the right table
            case left
            /// RIGHT (OUTER) JOIN: Return all records from the right table, and the matched records from the left table
            case right
            /// FULL (OUTER) JOIN: Return all records when there is a match in either left or right table
            case outer
        }
        
        /// `INNER`, `OUTER`, etc.
        public let method: Method
        
        /// The left-hand side of the join. References the local column.
        public let local: Column
        
        /// The right-hand side of the join. References the column being joined.
        public let foreign: Column
        
        /// Creates a new SQL `DataJoin`.
        public init(method: Method, local: Column, foreign: Column) {
            self.method = method
            self.local = local
            self.foreign = foreign
        }
    }
}
