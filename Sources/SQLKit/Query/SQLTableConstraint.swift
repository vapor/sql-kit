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
