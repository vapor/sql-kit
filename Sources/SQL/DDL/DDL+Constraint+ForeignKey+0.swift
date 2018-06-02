extension SQLQuery.DDL.Constraint {
    /// A single foreign key, referencing two columns.
    public struct ForeignKey {
        /// The local column being referenced.
        public var local: SQLQuery.DML.Column
        
        /// The foreign column being referenced.
        public var foreign: SQLQuery.DML.Column
        
        /// An optional `DataDefinitionForeignKeyAction` to apply on updates.
        public var onUpdate: Action?
        
        /// An optional `DataDefinitionForeignKeyAction` to apply on delete.
        public var onDelete: Action?
        
        /// Creates a new `DataDefinitionForeignKey`.
        public init(local: SQLQuery.DML.Column, foreign: SQLQuery.DML.Column, onUpdate: Action?, onDelete: Action?) {
            self.local = local
            self.foreign = foreign
            self.onUpdate = onUpdate
            self.onDelete = onDelete
        }
    }
}
