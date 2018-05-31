extension Query.DDL {
    /// Supported `DataDefinitionQuery` action types.
    public struct Statement: ExpressibleByStringLiteral {
        /// `CREATE` a table. Define a table, adding columns.
        public static var create: Statement { return "CREATE" }
        
        /// `CREATE IF NOT EXISTS`
        ///
        /// - parameters:
        ///     - ifNotExists: If `true`, the table will only be created if it does not already exist.
        public static func create(ifNotExists: Bool) -> Statement {
            return .init(verb: "CREATE", modifiers: ifNotExists ? ["IF NOT EXISTS"] : [])
        }
        
        /// `ALTER` a table. Add or remove columns.
        public static var alter: Statement { return "ALTER" }
        
        /// `DROP` a table. Removes all columns (and data).
        public static var drop: Statement { return "DROP" }
        
        /// `DROP IF EXISTS`
        ///
        /// - parameters:
        ///     - ifExists: If `true`, the table will only be dropped if it currently exists.
        public static func drop(ifExists: Bool) -> Statement {
            return .init(verb: "DROP", modifiers: ifExists ? ["IF EXISTS"] : [])
        }
        
        /// `TRUNCATE` a table. Removes all data.
        public static var truncate: Statement { return "TRUNCATE" }
        
        /// Statement verb, i.e., SELECT, INSERT, etc.
        public var verb: String
        
        /// Statement modifiers, i.e., IGNORE, IF NOT EXISTS
        public var modifiers: [String]
        
        /// Creates a new `DataManipulationStatement`.
        public init(verb: String, modifiers: [String] = []) {
            self.verb = verb.uppercased()
            self.modifiers = modifiers.map { $0.uppercased() }
        }
        
        /// See `ExpressibleByStringLiteral`.
        public init(stringLiteral value: String) {
            self.init(verb: value)
        }
    }
}
