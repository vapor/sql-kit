extension SQLSerializer {
    /// See `SQLSerializer`.
    public func serialize(query: DataManipulationQuery) -> (String, [Encodable]) {
        let table = makeEscapedString(from: query.table)
        var statement: [String] = []
        var binds: [Encodable] = []

        switch query.statement.verb {
        case "DELETE":
            statement.append(query.statement.verb)
            statement += query.statement.modifiers
            statement.append("FROM")
            statement.append(table)
        case "INSERT":
            statement.append(query.statement.verb)
            statement += query.statement.modifiers
            statement.append("INTO")
            statement.append(table)

            // no need to pass `NULL` values during INSERT
            let columns = query.columns.filter { column in
                switch column.value {
                case .null: return false
                default: return true
                }
            }

            statement.append(
                "(" + columns.map { makeEscapedString(from: $0.column.name) }.joined(separator: ", ") + ")"
            )
            statement.append("VALUES")
            var placeholders: [String] = []
            for column in columns {
                let (placeholder, values) = serialize(value: column.value)
                placeholders.append(placeholder)
                binds += values
            }
            statement.append("(" + placeholders.joined(separator: ", ") + ")")
        case "UPDATE":
            statement.append(query.statement.verb)
            statement += query.statement.modifiers
            statement.append(table)
            statement.append("SET")

            let set = query.columns.map { col -> String in
                let column = makeEscapedString(from: col.column.name)
                let (string, values) = serialize(value: col.value)
                binds += values
                return "\(column) = \(string)"
            }
            statement.append(set.joined(separator: ", "))
        default:
            statement.append(query.statement.verb)
            statement += query.statement.modifiers

            let columns: [String] = query.keys.map { serialize(key: $0) }
            statement.append(columns.joined(separator: ", "))

            statement.append("FROM")
            statement.append(table)
        }

        if !query.joins.isEmpty {
            statement.append(serialize(joins: query.joins))
        }

        if !query.predicates.isEmpty {
            statement.append("WHERE")
            let group = DataPredicateGroup(relation: .and, predicates: query.predicates)
            let (string, values) = serialize(predicate: group)
            statement.append(string)
            binds += values
        }

        if !query.groupBys.isEmpty {
            statement.append(serialize(groupBys: query.groupBys))
        }

        if !query.orderBys.isEmpty {
            statement.append(serialize(orderBys: query.orderBys))
        }
        
        if let limit = query.limit {
            statement.append("LIMIT \(limit)")
            if let offset = query.offset {
                statement.append("OFFSET \(offset)")
            }
        }

        return (statement.joined(separator: " "), binds)
    }

    /// See `SQLSerializer`.
    public func makePlaceholder() -> String {
        return "?"
    }
}
