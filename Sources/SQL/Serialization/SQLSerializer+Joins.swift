extension SQLSerializer {
    /// See `SQLSerializer`.
    public func serialize(joins: [SQLQuery.DML.Join]) -> String {
        return joins.map(serialize).joined(separator: " ")
    }

    /// See `SQLSerializer`.
    public func serialize(join: SQLQuery.DML.Join) -> String {
        var statement: [String] = []
        statement.append("JOIN")

        let foreignTable = makeEscapedString(from: join.foreign.table ?? "") // FIXME: this is an error
        statement.append(foreignTable)
        statement.append("ON")

        statement.append(serialize(column: join.local))
        statement.append("=")
        statement.append(serialize(column: join.foreign))

        return statement.joined(separator: " ")
    }
}
