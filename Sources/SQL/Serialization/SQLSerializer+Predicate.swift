extension SQLSerializer {
    /// See `SQLSerializer`.
    public func serialize(predicate: DataManipulationQuery.Predicates.Relation) -> String {
        switch predicate {
        case .and: return "AND"
        case .or: return "OR"
        }
    }

    /// Depending on the predicate item case, calls either:
    ///     - `serialize(predicateGroup:)`
    ///     - `serialize(predicate:)`
    /// This should likely not need to be overridden.
    /// See `SQLSerializer`.
    public func serialize(predicates relation: DataManipulationQuery.Predicates, binds: inout Binds) -> String {
        switch relation {
        case .group(let relation, let predicates):
            let method = serialize(predicate: relation)
            let statement = predicates.map { predicate in
                return serialize(predicates: predicate, binds: &binds)
            }
            return "(" + statement.joined(separator: " \(method) ") + ")"
        case .unit(let item): return serialize(predicate: item, binds: &binds)
        }
    }

    /// See `SQLSerializer`.
    public func serialize(predicate: DataManipulationQuery.Predicate, binds: inout Binds) -> String {
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
    public func serialize(comparison: DataManipulationQuery.Predicate.Comparison) -> String {
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
