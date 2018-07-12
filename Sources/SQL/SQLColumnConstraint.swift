/// SQL column data integrity constraint, i.e., `NOT NULL`, `PRIMARY KEY`, etc.
///
/// Used by `SQLColumnBuilder`.
public protocol SQLColumnConstraint: SQLSerializable {
    /// See `SQLIdentifier`.
    associatedtype Identifier: SQLIdentifier
    
    /// See `SQLColumnConstraintAlgorithm`.
    associatedtype Algorithm: SQLColumnConstraintAlgorithm
    
    /// Creates a new `SQLColumnConstraint` from desired algorithm and identifier.
    static func constraint(_ algorithm: Algorithm, _ identifier: Identifier?) -> Self
}

// MARK: Convenience

extension SQLColumnConstraint {
    /// Creates a new `PRIMARY KEY` column constraint with default `DEFAULT` settings
    /// and no constraint name.
    public static var primaryKey: Self {
        return .primaryKey(default: .default, identifier: nil)
    }
    
    /// Creates a new `PRIMARY KEY` column constraint.
    ///
    /// - parameters:
    ///     - default: Optional default value to use.
    ///     - identifier: Optional constraint name.
    /// - returns: New column constraint.
    public static func primaryKey(default: Algorithm.PrimaryKeyDefault? = nil, identifier: Identifier? = nil) -> Self {
        return .constraint(.primaryKey(`default`), identifier)
    }
    
    /// Creates a new `NOT NULL` column constraint with no constraint name.
    public static var notNull: Self {
        return .notNull(identifier: nil)
    }
    
    /// Creates a new `NOT NULL` column constraint.
    ///
    /// - parameters:
    ///     - identifier: Optional constraint name.
    /// - returns: New column constraint.
    public static func notNull(identifier: Identifier? = nil) -> Self {
        return .constraint(.notNull, identifier)
    }
    
    /// Creates a new `UNIQUE` column constraint.
    ///
    /// - parameters:
    ///     - identifier: Optional constraint name.
    /// - returns: New column constraint.
    public static func unique(identifier: Identifier? = nil) -> Self {
        return .constraint(.unique, identifier)
    }
    
    /// Creates a new `DEFAULT <expr>` column constraint.
    ///
    /// - parameters
    ///     - expression: Expression to evaluate when setting the default value.
    ///     - identifier: Optional constraint name.
    /// - returns: New column constraint.
    public static func `default`(
        _ expression: Algorithm.Expression,
        identifier: Identifier? = nil
    ) -> Self {
        return .constraint(.default(expression), identifier)
    }
    
    /// Creates a new `CHECK` column constraint.
    ///
    /// - Parameters:
    ///     - expression: Expression to evaluate when setting the constraint.
    /// - Returns: New column constraint.
    public static func check(_ expression: Algorithm.Expression) -> Self {
        return .constraint(.check(expression), nil)
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
    public static func references<T, V>(
        _ keyPath: KeyPath<T, V>,
        onDelete: Algorithm.ForeignKey.Action? = nil,
        onUpdate: Algorithm.ForeignKey.Action? = nil,
        identifier: Identifier? = nil
    ) -> Self
        where T: SQLTable
    {
        return references(.keyPath(keyPath), [.keyPath(keyPath)], onDelete: onDelete, onUpdate: onUpdate, identifier: identifier)
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
        _ foreignTable: Algorithm.ForeignKey.TableIdentifier,
        _ foreignColumns: [Algorithm.ForeignKey.Identifier],
        onDelete: Algorithm.ForeignKey.Action? = nil,
        onUpdate: Algorithm.ForeignKey.Action? = nil,
        identifier: Identifier? = nil
    ) -> Self {
        return .constraint(.foreignKey(.foreignKey(foreignTable, foreignColumns, onDelete: onDelete, onUpdate: onUpdate)), identifier)
    }
}


// MARK: Generic

/// Generic implementation of `SQLColumnConstraint`.
public struct GenericSQLColumnConstraint<Identifier, Algorithm>: SQLColumnConstraint
    where Identifier: SQLIdentifier, Algorithm: SQLColumnConstraintAlgorithm
{
    /// Convenience alias for self.
    public typealias `Self` = GenericSQLColumnConstraint<Identifier, Algorithm>
    
    /// See `SQLColumnConstraint`.
    public static func constraint(_ algorithm: Algorithm, _ identifier: Identifier?) -> Self {
        return .init(identifier: identifier, algorithm: algorithm)
    }
    
    /// See `SQLColumnConstraint`.
    public var identifier: Identifier?
    
    /// See `SQLColumnConstraint`.
    public var algorithm: Algorithm
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        if let identifier = self.identifier {
            return "CONSTRAINT " + identifier.serialize(&binds) + " " + algorithm.serialize(&binds)
        } else {
            return algorithm.serialize(&binds)
        }
    }
}
