extension SQLSerializer {
    /// See `SQLSerializer`.
    public func serialize(predicate group: DataPredicateGroup, binds: inout Binds) -> String {
        let method = serialize(predicate: group.relation)
        let statement = group.predicates.map { predicate in
            return serialize(predicate: predicate, binds: &binds)
        }
        return "(" + statement.joined(separator: " \(method) ") + ")"
    }

    /// See `SQLSerializer`.
    public func serialize(predicate: DataPredicateGroupRelation) -> String {
        switch predicate {
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
    public func serialize(predicate relation: DataPredicateItem, binds: inout Binds) -> String {
        switch relation {
        case .group(let group): return serialize(predicate: group, binds: &binds)
        case .predicate(let item): return serialize(predicate: item, binds: &binds)
        }
    }

    /// See `SQLSerializer`.
    public func serialize(predicate: DataPredicate, binds: inout Binds) -> String {
        // Cleanup the predicate, fixing high-level invalid or un-optimized SQL.
        // For example:
        //     "IN ()" -> "false"
        //     "IN (?)" -> "= ?"
        switch predicate.comparison {
        case .notIn, .in:
            switch predicate.value {
            case .binds(let values):
                switch values.count {
                case 0:
                    /// if serializing a subset filter with 0 values, we must use true or false
                    switch predicate.comparison {
                    case .notIn: return "1"
                    case .in: return "0"
                    default: break
                    }
                case 1:
                    var statement: [String] = []
                    statement.append(serialize(column: predicate.column))
                    /// if serializing a subset filter with 1 value, we should use just equals
                    switch predicate.comparison {
                    case .notIn: statement.append(serialize(comparison: .notEqual))
                    case .in: statement.append(serialize(comparison: .equal))
                    default: break
                    }
                    statement.append(serialize(value: predicate.value, binds: &binds))
                    return statement.joined(separator: " ")
                default: break
                }
            default: break
            }
        default: break
        }

        // Normal serialization continues here
        var statement: [String] = []
        statement.append(serialize(column: predicate.column))
        switch (predicate.comparison, predicate.value) {
        case (.equal, .null): statement.append("IS")
        case (.notEqual, .null): statement.append("IS NOT")
        default: statement.append(serialize(comparison: predicate.comparison))
        }
        statement.append(serialize(value: predicate.value, binds: &binds))
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
        case .custom(let sql): return sql
        }
    }
}
