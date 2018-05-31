extension Query.DDL {
    /// A single column in a DDL statement.
    public struct ColumnDefinition {
        public static func column(_ name: String, _ columnType: Database.ColumnType) -> ColumnDefinition {
            return .init(name: name, columnType: columnType)
        }
        
        /// The column's name.
        public var name: String

        /// The column's data type.
        public var columnType: Database.ColumnType

        /// Creates a new `DataDefinitionColumn`.
        public init(name: String, columnType: Database.ColumnType) {
            self.name = name
            self.columnType = columnType
        }
    }
}
