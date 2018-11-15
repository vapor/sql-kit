/// SQL column data integrity constraint, i.e., `NOT NULL`, `PRIMARY KEY`, etc.
///
/// See `SQLTableConstraint` for table contraints.
///
/// Used by `SQLColumnBuilder`.
public protocol SQLColumnConstraint: SQLSerializable {
    /// See `SQLIdentifier`.
    associatedtype Identifier: SQLIdentifier
    
    /// See `SQLColumnConstraintAlgorithm`.
    associatedtype ConstraintAlgorithm: SQLConstraintAlgorithm
    
    /// Creates a new `SQLColumnConstraint` from desired algorithm and identifier.
    static func constraint(
        algorithm: ConstraintAlgorithm,
        name: Identifier?
    ) -> Self
}

// MARK: Convenience

extension SQLColumnConstraint {
    /// Creates a new `PRIMARY KEY` column constraint with default `DEFAULT` settings
    /// and no constraint name.
    public static var primaryKey: Self {
        return .primaryKey(name: nil)
    }
    
    /// Creates a new `PRIMARY KEY` column constraint.
    ///
    /// - parameters:
    ///     - default: Optional default value to use.
    ///     - name: Optional constraint name.
    /// - returns: New column constraint.
    public static func primaryKey(
        name: Identifier? = nil
    ) -> Self {
        return .constraint(algorithm: .primaryKey, name: name)
    }
    
    /// Creates a new `NOT NULL` column constraint with no constraint name.
    public static var notNull: Self {
        return .notNull(name: nil)
    }
    
    /// Creates a new `NOT NULL` column constraint.
    ///
    /// - parameters:
    ///     - name: Optional constraint name.
    /// - returns: New column constraint.
    public static func notNull(name: Identifier? = nil) -> Self {
        return .constraint(
            algorithm: .notNull,
            name: name
        )
    }
    
    /// Creates a new `UNIQUE` column constraint.
    ///
    /// - parameters:
    ///     - name: Optional constraint name.
    /// - returns: New column constraint.
    public static func unique(name: Identifier? = nil) -> Self {
        return .constraint(
            algorithm: .unique,
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
        _ expression: ConstraintAlgorithm.Expression,
        name: Identifier? = nil
    ) -> Self {
        return .constraint(algorithm: .default(expression), name: name)
    }
    
    /// Creates a new `CHECK` column constraint.
    ///
    /// - Parameters:
    ///     - expression: Expression to evaluate when setting the constraint.
    /// - Returns: New column constraint.
    public static func check(_ expression: ConstraintAlgorithm.Expression) -> Self {
        return .constraint(algorithm: .check(expression), name: nil)
    }

    /// Creates a new `REFERENCES` column constraint.
    ///
    ///     .references(\Galaxy.id, onDelete: .delete)
    ///
    /// - Parameters:
    ///     - keyPath: Key path to referenced column.
    ///     - onDelete: Optional foreign key action to perform on delete.
    ///     - onUpdate: Optional foreign key action to perform on update.
    ///     - identifier: Optional constraint name.
    /// - Returns: New column constraint.
    public static func references(
        _ table: ConstraintAlgorithm.ForeignKey.Identifier,
        _ column: ConstraintAlgorithm.ForeignKey.Identifier,
        onDelete: ConstraintAlgorithm.ForeignKey.ForeignKeyAction? = nil,
        onUpdate: ConstraintAlgorithm.ForeignKey.ForeignKeyAction? = nil,
        name: Identifier? = nil
    ) -> Self {
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
    ///     .references("galaxy", ["id"], onDelete: .delete)
    ///
    /// - Parameters:
    ///     - foreignTable: Identifier of foreign table to reference.
    ///     - foreignColumns: One or more columns in foreign table to reference.
    ///     - onDelete: Optional foreign key action to perform on delete.
    ///     - onUpdate: Optional foreign key action to perform on update.
    ///     - identifier: Optional constraint name.
    /// - Returns: New column constraint.
    public static func references(
        table: ConstraintAlgorithm.ForeignKey.Identifier,
        columns: [ConstraintAlgorithm.ForeignKey.Identifier],
        onDelete: ConstraintAlgorithm.ForeignKey.ForeignKeyAction? = nil,
        onUpdate: ConstraintAlgorithm.ForeignKey.ForeignKeyAction? = nil,
        name: Identifier? = nil
    ) -> Self {
        return .constraint(
            algorithm: .foreignKey(.foreignKey(
                table: table,
                columns: columns,
                onDelete: onDelete,
                onUpdate: onUpdate
            )),
            name: name
        )
    }
}

//// MARK: Generic
//
///// Generic implementation of `SQLColumnConstraint`.
//public struct GenericSQLColumnConstraint<Identifier, Algorithm>: SQLColumnConstraint
//    where Identifier: SQLIdentifier, Algorithm: SQLColumnConstraintAlgorithm
//{
//    /// Convenience alias for self.
//    public typealias `Self` = GenericSQLColumnConstraint<Identifier, Algorithm>
//    
//    /// See `SQLColumnConstraint`.
//    public static func constraint(_ algorithm: Algorithm, _ identifier: Identifier?) -> Self {
//        return .init(identifier: identifier, algorithm: algorithm)
//    }
//    
//    /// See `SQLColumnConstraint`.
//    public var identifier: Identifier?
//    
//    /// See `SQLColumnConstraint`.
//    public var algorithm: Algorithm
//    
//    /// See `SQLSerializable`.
//    public func serialize(_ binds: inout [Encodable]) -> String {
//        if let identifier = self.identifier {
//            return "CONSTRAINT " + identifier.serialize(&binds) + " " + algorithm.serialize(&binds)
//        } else {
//            return algorithm.serialize(&binds)
//        }
//    }
//}
