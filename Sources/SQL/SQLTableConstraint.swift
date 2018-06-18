public protocol SQLTableConstraint: SQLSerializable {
    associatedtype Identifier: SQLIdentifier
    associatedtype Algorithm: SQLTableConstraintAlgorithm
    static func constraint(_ algorithm: Algorithm, _ identifier: Identifier?) -> Self
}

// MARK: Convenience

extension SQLTableConstraint {
    public static func primaryKey(
        _ columns: Algorithm.Identifier...,
        identifier: Identifier? = nil
    ) -> Self {
        return .constraint(.primaryKey(columns, .primaryKey()), identifier)
    }
    public static func unique(
        _ columns: Algorithm.Identifier...,
        identifier: Identifier? = nil
    ) -> Self {
        return .constraint(.unique(columns), identifier)
    }
    
    public static func foreignKey(
        _ columns: [Algorithm.Identifier],
        references foreignTable: Algorithm.ForeignKey.TableIdentifier,
        _ foreignColumns: [Algorithm.ForeignKey.Identifier],
        onDelete: Algorithm.ForeignKey.ConflictResolution? = nil,
        onUpdate: Algorithm.ForeignKey.ConflictResolution? = nil,
        identifier: Identifier? = nil
    ) -> Self {
        return .constraint(.foreignKey(columns, .foreignKey(foreignTable, foreignColumns, onDelete: onDelete, onUpdate: onUpdate)), identifier)
    }
}

// MARK: Generic

public struct GenericSQLTableConstraint<Identifier, Algorithm>: SQLTableConstraint
    where Identifier: SQLIdentifier, Algorithm: SQLTableConstraintAlgorithm
{
    public typealias `Self` = GenericSQLTableConstraint<Identifier, Algorithm>
    
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
