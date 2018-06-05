extension SQLQuery.DDL {
    /// `CONSTRAINT`
    public struct Constraint {
        public static func foreignKey(from local: SQLQuery.DML.Column, to foreign: SQLQuery.DML.Column, onUpdate: ForeignKey.Action? = nil, onDelete: ForeignKey.Action? = nil) -> Constraint {
            return self.init(storage: .foreignKey(.init(local: local, foreign: foreign, onUpdate: onUpdate, onDelete: onDelete)))
        }
        
        public static func unique(_ columns: [SQLQuery.DML.Column]) -> Constraint {
            return self.init(storage: .unique(.init(columns: columns)))
        }
        
        /// Internal storage type.
        /// - warning: Enum cases are subject to change.
        public enum Storage {
            /// `FOREIGN KEY`
            case foreignKey(ForeignKey)
            /// `UNIQUE`
            case unique(Unique)
        }
        
        /// Internal storage.
        /// - warning: Enum cases are subject to change.
        public let storage: Storage
    }
}
