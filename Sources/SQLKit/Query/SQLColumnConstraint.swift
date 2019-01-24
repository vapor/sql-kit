/// SQL column data integrity constraint, i.e., `NOT NULL`, `PRIMARY KEY`, etc.
///
/// See `SQLTableConstraint` for table contraints.
///
/// Used by `SQLColumnBuilder`.
public struct SQLColumnConstraint: SQLExpression {
    /// Creates a new `PRIMARY KEY` column constraint with default `DEFAULT` settings
    /// and no constraint name.
    public static var primaryKey: SQLColumnConstraint {
        return .primaryKey()
    }
    
    /// Creates a new `PRIMARY KEY` column constraint.
    ///
    /// - parameters:
    ///     - default: Optional default value to use.
    ///     - name: Optional constraint name.
    /// - returns: New column constraint.
    public static func primaryKey(
        autoIncrement: Bool = true,
        name: SQLIdentifier? = nil
    ) -> SQLColumnConstraint {
        return .init(
            algorithm: SQLConstraintAlgorithm.primaryKey(autoIncrement: autoIncrement),
            name: name
        )
    }
    
    /// Creates a new `NOT NULL` column constraint with no constraint name.
    public static var notNull: SQLColumnConstraint {
        return .notNull(name: nil)
    }
    
    /// Creates a new `NOT NULL` column constraint.
    ///
    /// - parameters:
    ///     - name: Optional constraint name.
    /// - returns: New column constraint.
    public static func notNull(name: SQLExpression? = nil) -> SQLColumnConstraint {
        return .init(
            algorithm: SQLConstraintAlgorithm.notNull,
            name: name
        )
    }
    
    /// Creates a new `REFERENCES` column constraint.
    ///
    ///     .references("galaxy", "id", onDelete: .delete)
    ///
    /// - Parameters:
    ///     - keyPath: Key path to referenced column.
    ///     - onDelete: Optional foreign key action to perform on delete.
    ///     - onUpdate: Optional foreign key action to perform on update.
    ///     - identifier: Optional constraint name.
    /// - Returns: New column constraint.
    public static func references(
        _ table: String,
        _ column: String,
        onDelete: SQLForeignKeyAction? = nil,
        onUpdate: SQLForeignKeyAction? = nil,
        name: String? = nil
    ) -> SQLColumnConstraint {
        return self.references(
            table: SQLIdentifier(table),
            columns: [SQLIdentifier(column)],
            onDelete: onDelete,
            onUpdate: onUpdate,
            name: name.flatMap(SQLIdentifier.init)
        )
    }
    
    /// Creates a new `REFERENCES` column constraint.
    ///
    /// - Parameters:
    ///     - keyPath: Key path to referenced column.
    ///     - onDelete: Optional foreign key action to perform on delete.
    ///     - onUpdate: Optional foreign key action to perform on update.
    ///     - identifier: Optional constraint name.
    /// - Returns: New column constraint.
    public static func references(
        _ table: SQLExpression,
        _ column: SQLExpression,
        onDelete: SQLExpression? = nil,
        onUpdate: SQLExpression? = nil,
        name: SQLExpression? = nil
    ) -> SQLColumnConstraint {
        return self.references(
            table: table,
            columns: [column],
            onDelete: onDelete,
            onUpdate: onUpdate,
            name: name
        )
    }
    

    /// Creates a new `REFERENCES` column constraint.
    ///
    /// - Parameters:
    ///     - foreignTable: Identifier of foreign table to reference.
    ///     - foreignColumns: One or more columns in foreign table to reference.
    ///     - onDelete: Optional foreign key action to perform on delete.
    ///     - onUpdate: Optional foreign key action to perform on update.
    ///     - identifier: Optional constraint name.
    /// - Returns: New column constraint.
    public static func references(
        table: SQLExpression,
        columns: [SQLExpression],
        onDelete: SQLExpression? = nil,
        onUpdate: SQLExpression? = nil,
        name: SQLExpression? = nil
    ) -> SQLColumnConstraint {
        return .init(
            algorithm: SQLForeignKey(
                table: table,
                columns: columns,
                onDelete: onDelete,
                onUpdate: onUpdate
            ),
            name: name
        )
    }

    
    /// Creates a new `UNIQUE` column constraint.
    ///
    /// - parameters:
    ///     - name: Optional constraint name.
    /// - returns: New column constraint.
    public static func unique(name: SQLExpression? = nil) -> SQLColumnConstraint {
        return .init(
            algorithm: SQLConstraintAlgorithm.unique,
            name: name
        )
    }
    
    /// Creates a new `DEFAULT <expr>` column constraint.
    ///
    /// - parameters
    ///     - expression: Expression to evaluate when setting the default value.
    ///     - identifier: Optional constraint name.
    /// - returns: New column constraint.
    public static func `default`(
        _ expression: SQLExpression,
        name: SQLExpression? = nil
    ) -> SQLColumnConstraint {
        return .init(algorithm: SQLConstraintAlgorithm.default(expression), name: name)
    }
    
    /// Creates a new `CHECK` column constraint.
    ///
    /// - Parameters:
    ///     - expression: Expression to evaluate when setting the constraint.
    /// - Returns: New column constraint.
    public static func check(_ expression: SQLExpression) -> SQLColumnConstraint {
        return .init(algorithm: SQLConstraintAlgorithm.check(expression), name: nil)
    }


    public var algorithm: SQLExpression
    public var name: SQLExpression?
    
    /// Creates a new `SQLColumnConstraint` from desired algorithm and identifier.
    public init(algorithm: SQLExpression, name: SQLExpression?) {
        self.algorithm = algorithm
        self.name = name
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        if let name = self.name {
            serializer.write("CONSTRAINT ")
            name.serialize(to: &serializer)
            serializer.write(" ")
        }
        self.algorithm.serialize(to: &serializer)
    }
}
