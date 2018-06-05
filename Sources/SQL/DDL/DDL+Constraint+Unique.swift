extension SQLQuery.DDL.Constraint {
    /// A unique constraint.
    public struct Unique {
        /// The column to be made unique
        public var columns: [SQLQuery.DML.Column]
        
        /// Creates a new `DataDefinitionUnique`.
        public init(columns: [SQLQuery.DML.Column]) {
            self.columns = columns
        }
    }
}
