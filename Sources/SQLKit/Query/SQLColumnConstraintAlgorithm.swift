/// Column constraint algorithms used by `SQLConstraint`
public enum SQLColumnConstraintAlgorithm: SQLExpression {
    /// `PRIMARY KEY`column constraint.
    case primaryKey(autoIncrement: Bool)

    /// `NOT NULL` column constraint.
    case notNull

    /// `UNIQUE` column constraint.
    case unique

    /// `CHECK` column constraint.
    case check(SQLExpression)

    /// `COLLATE` column constraint.
    case collateConstraint(name: SQLExpression)

    /// `DEFAULT` column constraint.
    case defaultConstraint(SQLExpression)

    /// `FOREIGN KEY` column constraint.
    case foreignKey(references: SQLExpression)

    /// `GENERATED ALWAYS AS` column constraint.
    case generated(SQLExpression)

    /// Just serializes `SQLExpression`
    case custom(SQLExpression)

    /// `PRIMARY KEY` with auto incrementing turned on.
    public static var primaryKey: SQLColumnConstraintAlgorithm {
        return .primaryKey(autoIncrement: true)
    }

    /// `COLLATE` column constraint.
    public static func collate(name: String) -> SQLColumnConstraintAlgorithm {
        return .collate(name: SQLIdentifier(name))
    }

    /// `COLLATE` column constraint.
    public static func collate(name: SQLExpression) -> SQLColumnConstraintAlgorithm {
        return .collateConstraint(name: name)
    }

    /// `DEFAULT` column constraint.
    public static func `default`(_ value: String) -> SQLColumnConstraintAlgorithm {
        return .defaultConstraint(SQLLiteral.string(value))
    }

    /// `DEFAULT` column constraint.
    public static func `default`<T: BinaryInteger>(_ value: T) -> SQLColumnConstraintAlgorithm {
        return .defaultConstraint(SQLLiteral.numeric("\(value)"))
    }

    /// `DEFAULT` column constraint.
    public static func `default`<T: FloatingPoint>(_ value: T) -> SQLColumnConstraintAlgorithm {
        return .defaultConstraint(SQLLiteral.numeric("\(value)"))
    }

    /// `DEFAULT` column constraint.
    public static func `default`(_ value: Bool) -> SQLColumnConstraintAlgorithm {
        return .defaultConstraint(SQLLiteral.boolean(value))
    }

    /// `DEFAULT` column constraint.
    public static func `default`(_ value: SQLExpression) -> SQLColumnConstraintAlgorithm {
        return .defaultConstraint(value)
    }

    /// `FOREIGN KEY` column constraint.
    public static func references(
        _ table: String,
        _ column: String,
        onDelete: SQLForeignKeyAction? = nil,
        onUpdate: SQLForeignKeyAction? = nil
    ) -> SQLColumnConstraintAlgorithm {
        return self.references(
            SQLIdentifier(table),
            SQLIdentifier(column),
            onDelete: onDelete,
            onUpdate: onUpdate
        )
    }

    /// `FOREIGN KEY` column constraint.
    public static func references(
        _ table: SQLExpression,
        _ column: SQLExpression,
        onDelete: SQLExpression? = nil,
        onUpdate: SQLExpression? = nil
    ) -> SQLColumnConstraintAlgorithm {
        return .foreignKey(
            references: SQLForeignKey(
                table: table,
                columns: [column],
                onDelete: onDelete,
                onUpdate: onUpdate
            )
        )
    }

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
            SQLGroupExpression(expression).serialize(to: &serializer)
        case .collateConstraint(name: let collate):
            serializer.write("COLLATE ")
            collate.serialize(to: &serializer)
        case .defaultConstraint(let expression):
            serializer.write("DEFAULT ")
            expression.serialize(to: &serializer)
        case .foreignKey(let foreignKey):
            foreignKey.serialize(to: &serializer)
        case .generated(let expression):
            serializer.write("GENERATED ALWAYS AS ")
            SQLGroupExpression(expression).serialize(to: &serializer)
            serializer.write(" STORED")
        case .custom(let expression):
            expression.serialize(to: &serializer)
        }
    }
}
