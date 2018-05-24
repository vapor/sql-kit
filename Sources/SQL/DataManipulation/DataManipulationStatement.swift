/// Supported SQL data statement types.
public struct DataManipulationStatement: ExpressibleByStringLiteral {
    /// `SELECT`
    public static func select(distinct: Bool = false) -> DataManipulationStatement {
        return .init(verb: "SELECT", modifiers: distinct ? ["DISTINCT"] : [])
    }

    /// `INSERT`
    public static func insert() -> DataManipulationStatement {
        return "INSERT"
    }

    /// `UPDATE`
    public static func update() -> DataManipulationStatement {
        return "UPDATE"
    }

    /// `DELETE`
    public static func delete() -> DataManipulationStatement {
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
