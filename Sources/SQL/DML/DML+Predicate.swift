extension Query.DML {
    /// Represents one or more nestable SQL predicates joined by `AND` or `OR`.
    public struct Predicate {
        public static func or(_ predicates: Predicate...) -> Predicate {
            return .or(predicates)
        }
        
        public static func and(_ predicates: Predicate...) -> Predicate {
            return .and(predicates)
        }
        
        public static func or(_ predicates: [Predicate] = []) -> Predicate {
            return .group(.or, predicates)
        }
        
        public static func and(_ predicates: [Predicate] = []) -> Predicate {
            return .group(.and, predicates)
        }
        
        public static func group(_ relation: Relation, _ predicates: [Predicate] = []) -> Predicate {
            return self.init(storage: .group(relation, predicates))
        }
        
        public static func predicate(_ column: Column, _ comparison: Comparison, _ value: Value) -> Predicate {
            return self.init(storage: .unit(column, comparison, value))
        }
        
        /// All suported SQL `DataPredicate` comparisons.
        public enum Comparison: Equatable {
            /// =
            case equal
            /// !=, <>
            case notEqual
            /// <
            case lessThan
            /// >
            case greaterThan
            /// <=
            case lessThanOrEqual
            /// >=
            case greaterThanOrEqual
            /// IN
            case `in`
            /// NOT IN
            case notIn
            /// BETWEEN
            case between
            /// LIKE
            case like
            /// NOT LIKE
            case notLike
            /// Raw SQL string
            case custom(String)
        }
        
        /// Supported data predicate relations.
        public enum Relation {
            /// AND
            case and
            /// OR
            case or
        }
        
        /// Internal storage enum.
        indirect enum Storage {
            /// A collection of `DataPredicate` items joined by AND or OR.
            case group(Relation, [Predicate])
            /// A single `DataPredicate`.
            case unit(Column, Comparison, Value)
        }
        
        /// Internal storage.
        let storage: Storage
    }
}

public func &&<Database>(_ lhs: Query<Database>.DML.Predicate, _ rhs: Query<Database>.DML.Predicate) -> Query<Database>.DML.Predicate {
    return .and(lhs, rhs)
}

public func ||<Database>(_ lhs: Query<Database>.DML.Predicate, _ rhs: Query<Database>.DML.Predicate) -> Query<Database>.DML.Predicate {
    return .or([lhs, rhs])
}

public func ==<Database>(_ column: Query<Database>.DML.Column, _ value: Query<Database>.DML.Value) -> Query<Database>.DML.Predicate {
    return .predicate(column, .equal, value)
}
