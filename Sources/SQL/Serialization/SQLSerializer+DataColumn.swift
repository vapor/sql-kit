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
        return string
    }

    /// See `SQLSerializer`.
    public func serialize(key: DataManipulationKey) -> String {
        switch key {
        case .all: return "*"
        case .column(let column, let key):
            let string = serialize(column: column)
            if let key = key {
                return string + " as " + makeEscapedString(from: key)
            } else {
                return string
            }
        case .computed(let computed, let key):
            let string = serialize(column: computed)
            if let key = key {
                return string + " as " + makeEscapedString(from: key)
            } else {
                return string
            }
        }
    }

    /// See `SQLSerializer`.
    public func serialize(column: DataManipulationColumn) -> (String, [Encodable]) {
        let (value, binds) = serialize(value: column.value)
        return (serialize(column: column.column) + " = " + value, binds)
    }

    /// See `SQLSerializer`.
    public func serialize(value: DataManipulationValue) -> (String, [Encodable]) {
        let string: String
        var binds: [Encodable]?

        switch value {
        case .column(let col): string = serialize(column: col)
        case .computed(let col): string = serialize(column: col)
        case .values(let values):
            switch values.count {
            case 1: string = makePlaceholder()
            default:
                let placeholders: [String] = (0..<values.count).map { _ in makePlaceholder() }
                string = "(" + placeholders.joined(separator: ", ") + ")"
            }
            binds = values
        case .subquery(let subquery):
            let (sql, values) = serialize(query: subquery)
            string = "(" + sql + ")"
            binds = values
        case .custom(let sql): string = sql
        case .null: string = "NULL"
        }

        return (string, binds ?? [])
    }
}
