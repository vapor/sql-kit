extension SQLQuery.DDL {
    /// A single column in a DDL statement.
    public struct ColumnDefinition {
        public struct ColumnType {
            public static func columnType(_ name: String, _ parameters: [String] = [], attributes: [String] = []) -> ColumnType {
                return .init(name: name, parameters: parameters, attributes: attributes)
            }
            
            public var name: String
            public var parameters: [String]
            public var attributes: [String]
            
            public init(name: String, parameters: [String] = [], attributes: [String] = []) {
                self.name = name
                self.parameters = parameters
                self.attributes = attributes
            }
        }
        
        public enum Default {
            case computed(SQLQuery.DML.ComputedColumn)
            case unescaped(String)
        }
        
        public var `default`: Default?
        
        public static func column(_ name: String, _ columnType: ColumnType) -> ColumnDefinition {
            return .init(name: name, columnType: columnType)
        }
        
        /// The column's name.
        public var name: String

        /// The column's data type.
        public var columnType: ColumnType

        /// Creates a new `DataDefinitionColumn`.
        public init(name: String, columnType: ColumnType) {
            self.name = name
            self.columnType = columnType
        }
    }
}
