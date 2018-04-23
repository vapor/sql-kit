extension SQLSerializer {
    /// See `SQLSerializer`.
    public func serialize(predicateGroup: DataPredicateGroup) -> String {
        let method = serialize(predicateGroupRelation: predicateGroup.relation)
        let group = predicateGroup.predicates.map(serialize).joined(separator: " \(method) ")
        return "(" + group + ")"
    }

    /// See `SQLSerializer`.
    public func serialize(predicateGroupRelation: DataPredicateGroupRelation) -> String {
        switch predicateGroupRelation {
        case .and: return "AND"
        case .or: return "OR"
        case .custom(let string): return string
        }
    }

    /// Depending on the predicate item case, calls either:
    ///     - `serialize(predicateGroup:)`
    ///     - `serialize(predicate:)`
    /// This should likely not need to be overridden.
    /// See `SQLSerializer`.
    public func serialize(predicateItem: DataPredicateItem) -> String {
        switch predicateItem {
        case .group(let group): return serialize(predicateGroup: group)
        case .predicate(let predicate): return serialize(predicate: predicate)
        }
    }

    /// See `SQLSerializer`.
    public func serialize(predicate: DataPredicate) -> String {
        var statement: [String] = []

        /// Cleanup the predicate, fixing high-level invalid or un-optimized SQL.
        /// For example:
        ///     "IN ()" -> "false"
        ///     "IN (?)" -> "= ?"
        var predicate = predicate
        switch predicate.comparison {
        case .notIn, .in:
            switch predicate.value {
            case .placeholders(let count):
                switch count {
                case 0:
                    /// if serializing a subset filter with 0 values, we must use true or false
                    switch predicate.comparison {
                    case .notIn: predicate.value = .custom(sql: "1")
                    case .in: predicate.value = .custom(sql: "0")
                    default: break
                    }
                    predicate.column.name = ""
                    predicate.comparison = .none
                case 1:
                    /// if serializing a subset filter with 1 value, we should use just equals
                    switch predicate.comparison {
                    case .notIn: predicate.comparison = .notEqual
                    case .in: predicate.comparison = .equal
                    default: break
                    }
                default: break
                }
            default: break
            }
        case .isNotNull, .isNull:
            // no values should follow IS NULL / IS NOT NULL
            predicate.value = .none
        default: break
        }

        /// Serialize the predicate column.
        if predicate.column.name.count > 0 {
            let escapedColumn = makeEscapedString(from: predicate.column.name)
            if let table = predicate.column.table {
                let escaped = makeEscapedString(from: table)
                statement.append("\(escaped).\(escapedColumn)")
            } else {
                statement.append(escapedColumn)
            }

        }

        /// Serialize the predicate comparison.
        let comparisonSQL = serialize(comparison: predicate.comparison)
        if comparisonSQL.count > 0 {
            statement.append(comparisonSQL)
        }

        /// Serialize the predicate value.
        switch predicate.value {
        case .column(let col):
            statement.append(serialize(column: col))
        case .subquery(let subquery):
            let sub = serialize(query: subquery)
            statement.append("(" + sub + ")")
        case .placeholders(let length):
            if length == 1 {
                statement.append(makePlaceholder(predicate: predicate))
            } else {
                var placeholders: [String] = []
                for _ in 0..<length {
                    placeholders.append(makePlaceholder(predicate: predicate))
                }
                statement.append("(" + placeholders.joined(separator: ", ") + ")")
            }
        case .custom(let string): statement.append(string)
        case .none: break
        }

        return statement.joined(separator: " ")
    }

    /// See `SQLSerializer`.
    public func makePlaceholder(predicate: DataPredicate) -> String {
        var statement: [String] = []

        switch predicate.comparison {
        case .between:
            statement.append(makePlaceholder(name: predicate.column.name + ".min"))
            statement.append("AND")
            statement.append(makePlaceholder(name: predicate.column.name + ".max"))
        default:
            statement.append(makePlaceholder(name: predicate.column.name))
        }

        return statement.joined(separator: " ")
    }

    /// See `SQLSerializer`.
    public func serialize(comparison: DataPredicateComparison) -> String {
        switch comparison {
        case .equal: return "="
        case .notEqual: return "!="
        case .lessThan: return "<"
        case .greaterThan: return ">"
        case .lessThanOrEqual: return "<="
        case .greaterThanOrEqual: return ">="
        case .`in`: return "IN"
        case .notIn: return "NOT IN"
        case .between: return "BETWEEN"
        case .like: return "LIKE"
        case .notLike: return "NOT LIKE"
        case .isNull: return "IS NULL"
        case .isNotNull: return "IS NOT NULL"
        case .none: return ""
        case .sql(let sql): return sql
        }
    }
}
