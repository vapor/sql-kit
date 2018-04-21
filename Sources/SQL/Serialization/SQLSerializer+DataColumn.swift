extension SQLSerializer {
    /// See `SQLSerializer`.
    public func serialize(column: DataColumn) -> String {
        let escapedName = makeEscapedString(from: column.name)

        let string: String
        if let table = column.table {
            let escapedTable = makeEscapedString(from: table)
            string = "\(escapedTable).\(escapedName)"
        } else {
            string = escapedName
        }

        if let key = column.key {
            return string + " as " + makeEscapedString(from: key)
        } else {
            return string
        }
    }
}
