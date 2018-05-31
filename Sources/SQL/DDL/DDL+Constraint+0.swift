extension Query.DDL {
    /// `CONSTRAINT`
    public struct Constraint {
        public static func foreignKey(from local: Query.DML.Column, to foreign: Query.DML.Column, onUpdate: ForeignKey.Action? = nil, onDelete: ForeignKey.Action? = nil) -> Constraint {
            return self.init(storage: .foreignKey(.init(local: local, foreign: foreign, onUpdate: onUpdate, onDelete: onDelete)))
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
