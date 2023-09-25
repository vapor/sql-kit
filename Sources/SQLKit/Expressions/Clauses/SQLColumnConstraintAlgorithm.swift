/// Column constraint algorithms used by ``SQLColumnDefinition``
public enum SQLColumnConstraintAlgorithm: SQLExpression {
    /// `PRIMARY KEY`column constraint.
    case primaryKey(autoIncrement: Bool)

    /// `NOT NULL` column constraint.
    case notNull

    /// `UNIQUE` column constraint.
    case unique

    /// `CHECK` column constraint.
    case check(any SQLExpression)

    /// `COLLATE` column constraint.
    case collate(name: any SQLExpression)

    /// `DEFAULT` column constraint.
    case `default`(any SQLExpression)

    /// `FOREIGN KEY` column constraint.
    case foreignKey(references: any SQLExpression)

    /// `GENERATED ALWAYS AS` column constraint.
    case generated(any SQLExpression)

    /// Just serializes ``SQLExpression``
    case custom(any SQLExpression)

    /// `PRIMARY KEY` with auto incrementing turned on.
    @inlinable
    public static var primaryKey: SQLColumnConstraintAlgorithm {
        .primaryKey(autoIncrement: true)
    }

    /// `COLLATE` column constraint.
    @inlinable
    public static func collate(name: String) -> SQLColumnConstraintAlgorithm {
        .collate(name: SQLIdentifier(name))
    }

    /// `DEFAULT` column constraint.
    @inlinable
    public static func `default`(_ value: String) -> SQLColumnConstraintAlgorithm {
        .default(SQLLiteral.string(value))
    }

    /// `DEFAULT` column constraint.
    @inlinable
    public static func `default`<T: BinaryInteger>(_ value: T) -> SQLColumnConstraintAlgorithm {
        .default(SQLLiteral.numeric("\(value)"))
    }

    /// `DEFAULT` column constraint.
    @inlinable
    public static func `default`<T: FloatingPoint>(_ value: T) -> SQLColumnConstraintAlgorithm {
        .default(SQLLiteral.numeric("\(value)"))
    }

    /// `DEFAULT` column constraint.
    @inlinable
    public static func `default`(_ value: Bool) -> SQLColumnConstraintAlgorithm {
        .default(SQLLiteral.boolean(value))
    }

    /// `FOREIGN KEY` column constraint.
    @inlinable
    public static func references(
        _ table: String,
        _ column: String,
        onDelete: SQLForeignKeyAction? = nil,
        onUpdate: SQLForeignKeyAction? = nil
    ) -> SQLColumnConstraintAlgorithm {
        self.references(
            SQLIdentifier(table),
            SQLIdentifier(column),
            onDelete: onDelete,
            onUpdate: onUpdate
        )
    }

    /// `FOREIGN KEY` column constraint.
    @inlinable
    public static func references(
        _ table: any SQLExpression,
        _ column: any SQLExpression,
        onDelete: (any SQLExpression)? = nil,
        onUpdate: (any SQLExpression)? = nil
    ) -> SQLColumnConstraintAlgorithm {
        .foreignKey(
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
            if autoIncrement {
                if serializer.database.dialect.supportsAutoIncrement {
                    if let function = serializer.database.dialect.autoIncrementFunction {
                        serializer.dialect.literalDefault.serialize(to: &serializer)
                        serializer.write(" ")
                        function.serialize(to: &serializer)
                        serializer.write(" ")
                        serializer.write("PRIMARY KEY")
                    } else {
                        serializer.write("PRIMARY KEY")
                        serializer.write(" ")
                        serializer.dialect.autoIncrementClause.serialize(to: &serializer)
                    }
                } else {
                    serializer.database.logger.warning("Autoincrement not supported, skipping")
                    serializer.write("PRIMARY KEY")
                }
            } else {
                serializer.write("PRIMARY KEY")
            }
        case .notNull:
            serializer.write("NOT NULL")
        case .unique:
            serializer.write("UNIQUE")
        case .check(let expression):
            serializer.write("CHECK ")
            SQLGroupExpression(expression).serialize(to: &serializer)
        case .collate(name: let collate):
            serializer.write("COLLATE ")
            collate.serialize(to: &serializer)
        case .default(let expression):
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
