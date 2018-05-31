extension SQLSerializer {
    /// See `SQLSerializer`.
    public func serialize(query: Query, binds: inout Binds) -> String {
        switch query.storage {
        case .ddl(let ddl): return serialize(query: ddl)
        case .dml(let dml): return serialize(query: dml, binds: &binds)
        }
    }
    
    /// See `SQLSerializer`.
    public func serialize(query: DML, binds: inout Binds) -> String {
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

            for (column, value) in query.columns {
                switch value.storage {
                case .null:
                    // no need to pass `NULL` values during INSERT
                    break
                default:
                    columns.append(serialize(column: column))
                    values.append(serialize(value: value, binds: &binds))
                }
            }

            statement.append("(" + columns.joined(separator: ", ") + ")")
            statement.append("VALUES")
            statement.append("(" + values.joined(separator: ", ") + ")")
        case "UPDATE":
            statement.append(table)
            statement.append("SET")
            statement.append(query.columns.map { data in
                serialize(column: data.key, value: data.value, binds: &binds)
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

        switch query.predicate.storage {
        case .group(_, let predicates):
            if !predicates.isEmpty {
                statement.append("WHERE")
                statement.append(serialize(predicate: query.predicate, binds: &binds))
            }
        case .unit:
            statement.append("WHERE")
            statement.append(serialize(predicate: query.predicate, binds: &binds))
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
