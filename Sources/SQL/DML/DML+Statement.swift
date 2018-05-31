extension Query.DML {
    /// Supported SQL data statement types.
    public struct Statement: ExpressibleByStringLiteral {
        /// `SELECT`
        public static var select: Statement {
            return .select(distinct: false)
        }
        
        /// `SELECT DISTINCT`
        ///
        /// - parameters:
        ///     - distinct: If `true`, only select distinct columns.
        public static func select(distinct: Bool) -> Statement {
            return .init(verb: "SELECT", modifiers: distinct ? ["DISTINCT"] : [])
        }
        
        /// `INSERT`
        public static var insert: Statement {
            return "INSERT"
        }
        
        /// `UPDATE`
        public static var update: Statement {
            return "UPDATE"
        }
        
        /// `DELETE`
        public static var delete: Statement {
            return "DELETE"
        }
        
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
