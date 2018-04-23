extension SQLSerializer {
    /// See `SQLSerializer`.
    public func serialize(column: DataComputedColumn) -> String {
        var serialized = column.function
        serialized += "("
        if column.columns.isEmpty {
            serialized += "*"
        } else {
            let cols = column.columns.map { serialize(column: $0) }
            serialized += cols.joined(separator: ", ")
        }
        serialized += ")"
        return serialized
    }
}
