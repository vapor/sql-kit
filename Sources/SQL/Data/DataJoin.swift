/// Represents a SQL join.
public struct DataJoin {
    /// `INNER`, `OUTER`, etc.
    public let method: DataJoinMethod

    /// The left-hand side of the join. References the local column.
    public let local: DataColumn

    /// The right-hand side of the join. References the column being joined.
    public let foreign: DataColumn

    /// Creates a new SQL `DataJoin`.
    public init(method: DataJoinMethod, local: DataColumn, foreign: DataColumn) {
        self.method = method
        self.local = local
        self.foreign = foreign
    }
}

