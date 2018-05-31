extension DDL {
    /// A single column in a DDL statement.
    public struct ColumnDefinition {
        public struct DataType: ExpressibleByStringLiteral {
            public static func dataType(_ name: String, parameters: [String] = [], attributes: [String] = []) -> DataType {
                return self.init(name: name, parameters: parameters, attributes: attributes)
            }
            
            /// VARCHAR
            public var name: String
            
            /// (a, b, c)
            public var parameters: [String]
            
            /// UNSIGNED, PRIMARY KEY
            public var attributes: [String]
            
            /// Creates a new `DataDefinitionDataType`.
            public init(name: String, parameters: [String], attributes: [String]) {
                self.name = name
                self.parameters = parameters
                self.attributes = attributes
            }
            
            /// See `ExpressibleByStringLiteral`.
            public init(stringLiteral value: String) {
                self.init(name: value, parameters: [], attributes: [])
            }
        }
        
        public static func column(_ name: String, _ dataType: DataType = .dataType("VOID")) -> ColumnDefinition {
            return .init(name: name, dataType: dataType)
        }
        
        /// The column's name.
        public var name: String

        /// The column's data type.
        public var dataType: DataType

        /// Creates a new `DataDefinitionColumn`.
        public init(name: String, dataType: DataType) {
            self.name = name
            self.dataType = dataType
        }
    }
}
