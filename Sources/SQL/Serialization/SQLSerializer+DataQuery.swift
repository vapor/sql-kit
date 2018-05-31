extension SQLSerializer {
    /// See `SQLSerializer`.
    public func serialize(query: Query<Database>, binds: inout Binds) -> String {
        switch query.storage {
        case .ddl(let ddl): return serialize(ddl: ddl)
        case .dml(let dml): return serialize(dml: dml, binds: &binds)
        }
    }
    
    /// See `SQLSerializer`.
    public func serialize(dml: Query<Database>.DML, binds: inout Binds) -> String {
        let table = makeEscapedString(from: dml.table)
        var statement: [String] = []
        statement.append(dml.statement.verb)
        statement += dml.statement.modifiers
        switch dml.statement.verb {
        case "DELETE":
            statement.append("FROM")
            statement.append(table)
        case "INSERT":
            statement.append("INTO")
            statement.append(table)

            var columns: [String] = []
            var values: [String] = []

            for (column, value) in dml.columns {
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
            statement.append(dml.columns.map { data in
                serialize(column: data.key, value: data.value, binds: &binds)
            }.joined(separator: ", "))
        default: // SELECT + others
            let keys = dml.keys.isEmpty ? [.all(table: nil)] : dml.keys
            statement.append(keys.map { serialize(key: $0) }.joined(separator: ", "))
            statement.append("FROM")
            statement.append(table)
        }

        if !dml.joins.isEmpty {
            statement.append(serialize(joins: dml.joins))
        }

        switch dml.predicate.storage {
        case .group(_, let predicates):
            if !predicates.isEmpty {
                statement.append("WHERE")
                statement.append(serialize(predicate: dml.predicate, binds: &binds))
            }
        case .unit:
            statement.append("WHERE")
            statement.append(serialize(predicate: dml.predicate, binds: &binds))
        }

        if !dml.groupBys.isEmpty {
            statement.append(serialize(groupBys: dml.groupBys))
        }

        if !dml.orderBys.isEmpty {
            statement.append(serialize(orderBys: dml.orderBys))
        }
        
        if let limit = dml.limit {
            statement.append("LIMIT \(limit)")
            if let offset = dml.offset {
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
