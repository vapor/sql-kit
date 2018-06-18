public protocol SQLColumnConstraint: SQLSerializable {
    associatedtype Identifier: SQLIdentifier
    associatedtype ColumnConstraintAlgorithm: SQLColumnConstraintAlgorithm
    static func constraint(_ algorithm: ColumnConstraintAlgorithm, _ identifier: Identifier?) -> Self
}

// MARK: Convenience

extension SQLColumnConstraint {
    public static var primaryKey: Self {
        return .primaryKey(identifier: nil)
    }
    
    /// Creates a new `PRIMARY KEY` column constraint.
    ///
    /// - parameters:
    ///     - identifier: Optional constraint name.
    /// - returns: New column constraint.
    public static func primaryKey(identifier: Identifier?) -> Self {
        return .constraint(.primaryKey(.primaryKey()), identifier)
    }
    
    public static var notNull: Self {
        return .notNull(identifier: nil)
    }
    
    /// Creates a new `NOT NULL` column constraint.
    ///
    /// - parameters:
    ///     - identifier: Optional constraint name.
    /// - returns: New column constraint.
    public static func notNull(identifier: Identifier?) -> Self {
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
        _ expression: ColumnConstraintAlgorithm.Expression,
        identifier: Identifier? = nil
    ) -> Self {
        return .constraint(.default(expression), identifier)
    }
    
    public static func references<T, V>(
        _ keyPath: KeyPath<T, V>,
        onDelete: ColumnConstraintAlgorithm.ForeignKey.ConflictResolution? = nil,
        onUpdate: ColumnConstraintAlgorithm.ForeignKey.ConflictResolution? = nil,
        identifier: Identifier? = nil
        ) -> Self
        where T: SQLTable
    {
        return references(.keyPath(keyPath), [.keyPath(keyPath)], onDelete: onDelete, onUpdate: onUpdate, identifier: identifier)
    }
    
    public static func references(
        _ foreignTable: ColumnConstraintAlgorithm.ForeignKey.TableIdentifier,
        _ foreignColumns: [ColumnConstraintAlgorithm.ForeignKey.Identifier],
        onDelete: ColumnConstraintAlgorithm.ForeignKey.ConflictResolution? = nil,
        onUpdate: ColumnConstraintAlgorithm.ForeignKey.ConflictResolution? = nil,
        identifier: Identifier? = nil
        ) -> Self {
        return .constraint(.foreignKey(.foreignKey(foreignTable, foreignColumns, onDelete: onDelete, onUpdate: onUpdate)), identifier)
    }
}


// MARK: Generic

public struct GenericSQLColumnConstraint<Identifier, ColumnConstraintAlgorithm>: SQLColumnConstraint
    where Identifier: SQLIdentifier, ColumnConstraintAlgorithm: SQLColumnConstraintAlgorithm
{
    public typealias `Self` = GenericSQLColumnConstraint<Identifier, ColumnConstraintAlgorithm>
    
    /// See `SQLColumnConstraint`.
    public static func constraint(_ algorithm: ColumnConstraintAlgorithm, _ identifier: Identifier?) -> Self {
        return .init(identifier: identifier, algorithm: algorithm)
    }
    
    public var identifier: Identifier?
    
    public var algorithm: ColumnConstraintAlgorithm
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        if let identifier = self.identifier {
            return "CONSTRAINT " + identifier.serialize(&binds) + " " + algorithm.serialize(&binds)
        } else {
            return algorithm.serialize(&binds)
        }
    }
}
