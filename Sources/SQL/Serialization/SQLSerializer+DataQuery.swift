extension SQLSerializer {
    /// See `SQLSerializer`.
    public func serialize(query: DataQuery) -> String {
        let table = makeEscapedString(from: query.table)
        var statement: [String] = []
        statement.append("SELECT")
        if query.distinct == true {
            statement.append("DISTINCT")
        }

        let columns: [String] = query.columns.map { serialize(column: $0) }
        statement.append(columns.joined(separator: ", "))

        statement.append("FROM")
        statement.append(table)


        if !query.joins.isEmpty {
            statement.append(serialize(joins: query.joins))
        }

        if !query.predicates.isEmpty {
            statement.append("WHERE")
            let group = DataPredicateGroup(relation: .and, predicates: query.predicates)
            statement.append(serialize(predicateGroup: group))
        }

        if !query.orderBys.isEmpty {
            statement.append(serialize(orderBys: query.orderBys))
        }

        if !query.groupBys.isEmpty {
            statement.append(serialize(groupBys: query.groupBys))
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
    public func serialize(query: DataManipulationQuery) -> String {
        let table = makeEscapedString(from: query.table)
        var statement: [String] = []

        switch query.statement {
        case .delete:
            statement.append("DELETE FROM")
            statement.append(table)
        case .insert:
            statement.append("INSERT INTO")
            statement.append(table)

            let columns = query.columns.map { makeEscapedString(from: $0.column.name) }
            statement.append("(" + columns.joined(separator: ", ") + ")")
            statement.append("VALUES")

            let placeholders = query.columns.map { serialize(value: $0.value) }
            statement.append("(" + placeholders.joined(separator: ", ") + ")")
        case .update:
            statement.append("UPDATE")
            statement.append(table)
            statement.append("SET")

            let set = query.columns.map { col -> String in
                let column = makeEscapedString(from: col.column.name)
                let value = serialize(value: col.value)
                return "\(column) = \(value)"
            }
            statement.append(set.joined(separator: ", "))
        }

        if !query.joins.isEmpty {
            statement.append(serialize(joins: query.joins))
        }

        if !query.predicates.isEmpty {
            statement.append("WHERE")
            let group = DataPredicateGroup(relation: .and, predicates: query.predicates)
            statement.append(serialize(predicateGroup: group))
        }
        
        if let limit = query.limit {
            statement.append("LIMIT \(limit)")
        }

        return statement.joined(separator: " ")
    }

    /// See `SQLSerializer`.
    public func serialize(value: DataManipulationValue) -> String {
        switch value {
        case .column(let col): return serialize(column: col)
        case .computed(let col): return serialize(column: col)
        case .placeholder: return makePlaceholder()
        case .subquery(let subquery): return "(" + serialize(query: subquery) + ")"
        case .custom(let sql): return sql
        }
    }

    /// See `SQLSerializer`.
    public func makePlaceholder() -> String {
        return "?"
    }
}
