/// Table constraint algorithms used by ``SQLCreateTable``.
public enum SQLTableConstraintAlgorithm: SQLExpression {
    /// `PRIMARY KEY` table constraint.
    case primaryKey(columns: [any SQLExpression])

    /// `UNIQUE` table constraint.
    case unique(columns: [any SQLExpression])

    /// `CHECK` table constraint.
    case check(any SQLExpression)

    /// `FOREIGN KEY` table constraint.
    case foreignKey(columns: [any SQLExpression], references: any SQLExpression)

    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .primaryKey(columns: let columns):
            serializer.write("PRIMARY KEY ")
            SQLGroupExpression(columns).serialize(to: &serializer)
        case .unique(columns: let columns):
            serializer.write("UNIQUE ")
            SQLGroupExpression(columns).serialize(to: &serializer)
        case .check(let expression):
            serializer.write("CHECK ")
            SQLGroupExpression(expression).serialize(to: &serializer)
        case .foreignKey(columns: let columns, let foreignKey):
            serializer.write("FOREIGN KEY ")
            SQLGroupExpression(columns).serialize(to: &serializer)
            serializer.write(" ")
            foreignKey.serialize(to: &serializer)
        }
    }
}
