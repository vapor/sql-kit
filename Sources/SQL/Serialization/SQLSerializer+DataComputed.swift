extension SQLSerializer {
    /// See `SQLSerializer`.
    public func serialize(column: SQLQuery.DML.ComputedColumn) -> String {
        var serialized = column.function
        serialized += "("
        serialized += column.keys.map { serialize(key: $0) }.joined(separator: ", ")
        serialized += ")"
        return serialized
    }
}
