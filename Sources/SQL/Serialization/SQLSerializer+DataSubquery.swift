extension SQLSerializer {
    /// See `SQLSerializer`.
    public func serialize(column: DataSubqueryColumn) -> String {
        let serialized = "(\(column.query))"
        return serialized
    }
}
