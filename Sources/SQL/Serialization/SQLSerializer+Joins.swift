extension SQLSerializer {
    /// See `SQLSerializer`.
    public func serialize(joins: [DataJoin]) -> String {
        return joins.map(serialize).joined(separator: " ")
    }

    /// See `SQLSerializer`.
    public func serialize(join: DataJoin) -> String {
        var statement: [String] = []
        
        switch join.method {
        case .inner:
            statement.append("INNER JOIN")
        case .outer:
            statement.append("LEFT OUTER JOIN")
        }
        

        let foreignTable = makeEscapedString(from: join.foreign.table ?? "") // FIXME: this is an error
        statement.append(foreignTable)
        statement.append("ON")

        statement.append(serialize(column: join.local))
        statement.append("=")
        statement.append(serialize(column: join.foreign))

        return statement.joined(separator: " ")
    }
}
