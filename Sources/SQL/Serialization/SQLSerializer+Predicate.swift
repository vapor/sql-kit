extension SQLSerializer {
    /// See `SQLSerializer`.
    public func serialize(predicate: DML.Predicate.Relation) -> String {
        switch predicate {
        case .and: return "AND"
        case .or: return "OR"
        }
    }

    /// See `SQLSerializer`.
    public func serialize(predicate: DML.Predicate, binds: inout Binds) -> String {
        // Cleanup the predicate, fixing high-level invalid or un-optimized SQL.
        // For example:
        //     "IN ()" -> "false"
        //     "IN (?)" -> "= ?"
        switch predicate.storage {
        case .group(let relation, let predicates):
            let method = serialize(predicate: relation)
            let statement = predicates.map { predicate in
                return serialize(predicate: predicate, binds: &binds)
            }
            return "(" + statement.joined(separator: " \(method) ") + ")"
        case .unit(let column, let comparison, let value):
            switch comparison {
            case .notIn, .in:
                switch value.storage {
                case .binds(let values):
                    switch values.count {
                    case 0:
                        /// if serializing a subset filter with 0 values, we must use true or false
                        switch comparison {
                        case .notIn: return "1"
                        case .in: return "0"
                        default: break
                        }
                    case 1:
                        var statement: [String] = []
                        statement.append(serialize(column: column))
                        /// if serializing a subset filter with 1 value, we should use just equals
                        switch comparison {
                        case .notIn: statement.append(serialize(comparison: .notEqual))
                        case .in: statement.append(serialize(comparison: .equal))
                        default: break
                        }
                        statement.append(serialize(value: value, binds: &binds))
                        return statement.joined(separator: " ")
                    default: break
                    }
                default: break
                }
            default: break
            }

            // Normal serialization continues here
            var statement: [String] = []
            statement.append(serialize(column: column))
            switch (comparison, value.storage) {
            case (.equal, .null): statement.append("IS")
            case (.notEqual, .null): statement.append("IS NOT")
            default: statement.append(serialize(comparison: comparison))
            }
            statement.append(serialize(value: value, binds: &binds))
            return statement.joined(separator: " ")
        }
    }

    /// See `SQLSerializer`.
    public func serialize(comparison: DML.Predicate.Comparison) -> String {
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
