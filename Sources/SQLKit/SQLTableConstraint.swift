/// SQL table data integrity constraint, i.e., `FOREIGN KEY`, `UNIQUE`, etc.
///
/// See `SQLColumnConstraint` for column constraints.
public protocol SQLTableConstraint: SQLSerializable {
    /// See `SQLIdentifier`.
    associatedtype Identifier: SQLIdentifier
    
    /// See `SQLTableConstraintAlgorithm`.
    associatedtype ConstraintAlgorithm: SQLConstraintAlgorithm
    
    /// Creates a new `SQLTableConstraint` from desired algorithm and identifier.
    static func constraint(
        algorithm: ConstraintAlgorithm,
        columns: [Identifier],
        name: Identifier?
    ) -> Self
}

// MARK: Convenience

extension SQLTableConstraint {
    /// Creates a new `PRIMARY KEY` table constraint on one or more specified columns.
    /// An optional name can be supplied to identify constraint.
    public static func primaryKey(
        _ columns: Identifier...,
        name: Identifier? = nil
    ) -> Self {
        return .constraint(
            algorithm: .primaryKey,
            columns: columns,
            name: name
        )
    }
    
    /// Creates a new `UNIQUE` table constraint on one or more specified columns.
    /// An optional name can be supplied to identify constraint.
    public static func unique(
        _ columns: Identifier...,
        name: Identifier? = nil
    ) -> Self {
        return .constraint(
            algorithm: .unique,
            columns: columns,
            name: name
        )
    }
    
    /// Creates a new `FOREIGN` table constraint on one or more specified columns
    /// referencing one or more specified columns on a foreign table.
    ///
    /// `ON DELETE` and `ON UPDATE` actions can also be specified.
    ///
    /// An optional name can be supplied to identify constraint.
    public static func foreignKey(
        _ columns: [Identifier],
        references foreignTable: ConstraintAlgorithm.ForeignKey.Identifier,
        _ foreignColumns: [ConstraintAlgorithm.ForeignKey.Identifier],
        onDelete: ConstraintAlgorithm.ForeignKey.ForeignKeyAction? = nil,
        onUpdate: ConstraintAlgorithm.ForeignKey.ForeignKeyAction? = nil,
        name: Identifier? = nil
    ) -> Self {
        return .constraint(
            algorithm: .foreignKey(.foreignKey(
                table: foreignTable,
                columns: foreignColumns,
                onDelete: onDelete,
                onUpdate: onUpdate
            )),
            columns: columns,
            name: name
        )
    }
}

// MARK: Generic
//
///// Generic implementation of `SQLTableConstraint`.
//public struct GenericSQLTableConstraint<Identifier, Algorithm>: SQLTableConstraint
//    where Identifier: SQLIdentifier, Algorithm: SQLTableConstraintAlgorithm
//{
//    /// Convenience typealias for self.
//    public typealias `Self` = GenericSQLTableConstraint<Identifier, Algorithm>
//    
//    /// See `SQLColumnConstraint`.
//    public static func constraint(_ algorithm: Algorithm, _ identifier: Identifier?) -> Self {
//        return .init(identifier: identifier, algorithm: algorithm)
//    }
//    
//    /// See `SQLTableConstraint`.
//    public var identifier: Identifier?
//    
//    /// See `SQLTableConstraint`.
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
