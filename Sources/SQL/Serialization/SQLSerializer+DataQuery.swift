extension SQLSerializer {
    /// See `SQLSerializer`.
    public func serialize(query: DataManipulationQuery, binds: inout Binds) -> String {
        let table = makeEscapedString(from: query.table)
        var statement: [String] = []
        statement.append(query.statement.verb)
        statement += query.statement.modifiers
        switch query.statement.verb {
        case "DELETE":
            statement.append("FROM")
            statement.append(table)
        case "INSERT":
            statement.append("INTO")
            statement.append(table)

            var columns: [String] = []
            var values: [String] = []

            for column in query.columns {
                switch column.value {
                case .null:
                    // no need to pass `NULL` values during INSERT
                    break
                default:
                    columns.append(serialize(column: column.column))
                    values.append(serialize(value: column.value, binds: &binds))
                }
            }

            statement.append("(" + columns.joined(separator: ", ") + ")")
            statement.append("VALUES")
            statement.append("(" + values.joined(separator: ", ") + ")")
        case "UPDATE":
            statement.append(table)
            statement.append("SET")
            statement.append(query.columns.map {
                serialize(column: $0, binds: &binds)
            }.joined(separator: ", "))
        default: // SELECT + others
            let keys = query.keys.isEmpty ? [.all(table: nil)] : query.keys
            statement.append(keys.map { serialize(key: $0) }.joined(separator: ", "))
            statement.append("FROM")
            statement.append(table)
        }

        if !query.joins.isEmpty {
            statement.append(serialize(joins: query.joins))
        }

        if !query.predicates.isEmpty {
            statement.append("WHERE")
            let group = DataPredicateGroup(relation: .and, predicates: query.predicates)
            statement.append(serialize(predicate: group, binds: &binds))
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

        return statement.joined(separator: " ")
    }

    /// See `SQLSerializer`.
    public func makePlaceholder() -> String {
        return "?"
    }
}
