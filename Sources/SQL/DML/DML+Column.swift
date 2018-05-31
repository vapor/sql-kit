extension Query.DML {
    /// Represents a SQL column with optional table name.
    public struct Column: ExpressibleByStringLiteral, Hashable {
        /// See `Hashable.`
        public var hashValue: Int {
            if let table = table {
                return table.hashValue &+ name.hashValue
            } else {
                return name.hashValue
            }
        }
        
        /// Table name for this column. If `nil`, it will be omitted.
        public var table: String?
        
        /// Column's name. Unique within the scope of a single table.
        public var name: String
        
        /// Creates a new SQL `DataColumn`.
        ///
        /// - parameters:
        ///     - table: Table name for this column. Defaults to `nil`.
        ///     - name: Column's name. Unique within the scope of a single table.
        public init(table: String? = nil, name: String) {
            self.table = table
            self.name = name
        }
        
        /// See `ExpressibleByStringLiteral`.
        public init(stringLiteral value: String) {
            self.init(name: value)
        }
    }
}
