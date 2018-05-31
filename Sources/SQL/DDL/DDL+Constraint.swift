extension DDL {
    /// `CONSTRAINT`
    public struct Constraint {
        public static func foreignKey(from local: DML.Column, to foreign: DML.Column, onUpdate: ForeignKey.Action? = nil, onDelete: ForeignKey.Action? = nil) -> Constraint {
            return self.init(storage: .foreignKey(.init(local: local, foreign: foreign, onUpdate: onUpdate, onDelete: onDelete)))
        }
        
        /// A single foreign key, referencing two columns.
        public struct ForeignKey {
            /// Foreign key actions to apply when data related via a foreign key is updated or deleted.
            public enum Action {
                /// Do nothing.
                case noAction
                
                /// Restrict the operation, this is the default.
                case restrict
                
                /// Set the relation to null.
                case setNull
                
                /// Set the relation to default values.
                case setDefault
                
                /// Cascade the operation. For example, if an entity is deleted
                /// then also delete the related entity.
                case cascade
            }
            
            /// The local column being referenced.
            public var local: DML.Column
            
            /// The foreign column being referenced.
            public var foreign: DML.Column
            
            /// An optional `DataDefinitionForeignKeyAction` to apply on updates.
            public var onUpdate: Action?
            
            /// An optional `DataDefinitionForeignKeyAction` to apply on delete.
            public var onDelete: Action?
            
            /// Creates a new `DataDefinitionForeignKey`.
            public init(local: DML.Column, foreign: DML.Column, onUpdate: Action?, onDelete: Action?) {
                self.local = local
                self.foreign = foreign
                self.onUpdate = onUpdate
                self.onDelete = onDelete
            }
        }
        
        /// A unique constraint.
        public struct Unique {
            /// The column to be made unique
            public var columns: [DML.Column]
            
            /// Creates a new `DataDefinitionUnique`.
            public init(columns: [DML.Column]) {
                self.columns = columns
            }
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
