extension SQLSerializer {
    /// See `SQLSerializer`.
    public func serialize(column: SQLQuery.DML.Column) -> String {
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
    public func serialize(key: SQLQuery.DML.Key) -> String {
        switch key.storage {
        case .all(let table):
            if let table = table {
                let escapedTable = makeEscapedString(from: table)
                return escapedTable + ".*"
            } else {
                return "*"
            }
        case .column(let column, let key):
            let string = serialize(column: column)
            if let key = key {
                return string + " AS " + makeEscapedString(from: key)
            } else {
                return string
            }
        case .computed(let computed, let key):
            let string = serialize(column: computed)
            if let key = key {
                return string + " AS " + makeEscapedString(from: key)
            } else {
                return string
            }
        }
    }

    /// See `SQLSerializer`.
    public func serialize(column: SQLQuery.DML.Column, value: SQLQuery.DML.Value, binds: inout Binds) -> String {
        return makeEscapedString(from: column.name) + " = " + serialize(value: value, binds: &binds)
    }

    /// See `SQLSerializer`.
    public func serialize(value: SQLQuery.DML.Value, binds: inout Binds) -> String {
        switch value.storage {
        case .column(let col): return serialize(column: col)
        case .computed(let col): return serialize(column: col)
        case .binds(let values):
            binds.values += values
            switch values.count {
            case 1: return makePlaceholder()
            default:
                let placeholders: [String] = (0..<values.count).map { _ in makePlaceholder() }
                return "(" + placeholders.joined(separator: ", ") + ")"
            }
        case .subquery(let dml): return "(" + serialize(dml: dml, binds: &binds) + ")"
        case .null: return "NULL"
        case .unescaped(let sql): return sql
        }
    }
}
