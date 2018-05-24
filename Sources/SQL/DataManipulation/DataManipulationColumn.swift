/// A DML column and value.
public struct DataManipulationColumn: ExpressibleByStringLiteral {
    /// Column to update.
    public var column: DataColumn

    /// Value to update column with.
    public var value: DataManipulationValue

    /// Creates a new `DataManipulationColumn`.
    public init(column: DataColumn, value: DataManipulationValue = .null) {
        self.column = column
        self.value = value
    }

    /// See `ExpressibleByStringLiteral`.
    public init(stringLiteral value: String) {
        self.init(column: .init(stringLiteral: value))
    }
}
