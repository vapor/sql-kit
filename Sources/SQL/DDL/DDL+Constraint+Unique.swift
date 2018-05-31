extension Query.DDL.Constraint {
    /// A unique constraint.
    public struct Unique {
        /// The column to be made unique
        public var columns: [Query.DML.Column]
        
        /// Creates a new `DataDefinitionUnique`.
        public init(columns: [Query.DML.Column]) {
            self.columns = columns
        }
    }
}
