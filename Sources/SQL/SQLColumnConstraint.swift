public protocol SQLColumnConstraint: SQLSerializable {
    associatedtype Identifier: SQLIdentifier
    associatedtype Algorithm: SQLColumnConstraintAlgorithm
    static func constraint(_ algorithm: Algorithm, _ identifier: Identifier?) -> Self
}

// MARK: Convenience

extension SQLColumnConstraint {
    public static var primaryKey: Self {
        return .primaryKey(default: .default, identifier: nil)
    }
    
    /// Creates a new `PRIMARY KEY` column constraint.
    ///
    /// - parameters:
    ///     - identifier: Optional constraint name.
    /// - returns: New column constraint.
    public static func primaryKey(default: Algorithm.PrimaryKeyDefault? = nil, identifier: Identifier? = nil) -> Self {
        return .constraint(.primaryKey(`default`), identifier)
    }
    
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
    
    public static func references<T, V>(
        _ keyPath: KeyPath<T, V>,
        onDelete: Algorithm.ForeignKey.ConflictResolution? = nil,
        onUpdate: Algorithm.ForeignKey.ConflictResolution? = nil,
        identifier: Identifier? = nil
        ) -> Self
        where T: SQLTable
    {
        return references(.keyPath(keyPath), [.keyPath(keyPath)], onDelete: onDelete, onUpdate: onUpdate, identifier: identifier)
    }
    
    public static func references(
        _ foreignTable: Algorithm.ForeignKey.TableIdentifier,
        _ foreignColumns: [Algorithm.ForeignKey.Identifier],
        onDelete: Algorithm.ForeignKey.ConflictResolution? = nil,
        onUpdate: Algorithm.ForeignKey.ConflictResolution? = nil,
        identifier: Identifier? = nil
        ) -> Self {
        return .constraint(.foreignKey(.foreignKey(foreignTable, foreignColumns, onDelete: onDelete, onUpdate: onUpdate)), identifier)
    }
}


// MARK: Generic

public struct GenericSQLColumnConstraint<Identifier, Algorithm>: SQLColumnConstraint
    where Identifier: SQLIdentifier, Algorithm: SQLColumnConstraintAlgorithm
{
    public typealias `Self` = GenericSQLColumnConstraint<Identifier, Algorithm>
    
    /// See `SQLColumnConstraint`.
    public static func constraint(_ algorithm: Algorithm, _ identifier: Identifier?) -> Self {
        return .init(identifier: identifier, algorithm: algorithm)
    }
    
    public var identifier: Identifier?
    
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
