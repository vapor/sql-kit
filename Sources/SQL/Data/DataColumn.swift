/// A SQL data column with optional table name.
public struct DataColumn: ExpressibleByStringLiteral {
    /// The table name for this column. If `nil`, it will be omitted.
    public var table: String?

    /// This column's name.
    public var name: String

    /// Creates a new SQL `DataColumn`.
    public init(table: String? = nil, name: String) {
        self.table = table
        self.name = name
    }

    /// See `ExpressibleByStringLiteral`.
    public init(stringLiteral value: String) {
        self.init(name: value)
    }
}
