/// Constraint algorithms used by `SQLColumnConstraint`.
public enum SQLConstraintAlgorithm: SQLExpression {
    /// `PRIMARY KEY` constraint.
    case primaryKey(autoIncrement: Bool)
    
    /// `NOT NULL` constraint.
    case notNull
    
    /// `UNIQUE` constraint.
    case unique
    
    /// `COLLATE` constraint.
    case check(SQLExpression)
    
    case collate(SQLExpression)
    
    /// `DEFAULT` constraint.
    case `default`(SQLExpression)
    
    /// `FOREIGN KEY` constraint.
    case foreignKey(SQLExpression)
    
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .primaryKey(let autoIncrement):
            serializer.write("PRIMARY KEY")
            if autoIncrement {
                serializer.write(" ")
                serializer.dialect.autoIncrementClause.serialize(to: &serializer)
            }
        case .notNull:
            serializer.write("NOT NULL")
        case .unique:
            serializer.write("UNIQUE")
        case .check(let expression):
            serializer.write("CHECK ")
            expression.serialize(to: &serializer)
        case .collate(let collate):
            serializer.write("COLLATE ")
            collate.serialize(to: &serializer)
        case .default(let expression):
            serializer.write("DEFAULT ")
            expression.serialize(to: &serializer)
        case .foreignKey(let foreignKey):
            serializer.write("FOREIGN KEY")
            foreignKey.serialize(to: &serializer)
        }
    }
}
