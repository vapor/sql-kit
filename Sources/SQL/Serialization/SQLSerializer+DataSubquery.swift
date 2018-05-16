extension SQLSerializer {
    /// See `SQLSerializer`.
    public func serialize(column: DataSubqueryColumn) -> String {
        let query = serialize(query: column.query)
        let serialized = "(\(query))"
        return serialized
    }
}
