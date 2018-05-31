/// `CONSTRAINT`
public enum DataDefinitionConstraint {
    /// `FOREIGN KEY`
    case foreignKey(DataDefinitionForeignKey)
    
    /// `UNIQUE`
    case unique(DataDefinitionUnique)
}
