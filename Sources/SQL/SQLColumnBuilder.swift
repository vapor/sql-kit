/// Builds data-definition queries that support creating columns, i.e., `CREATE TABLE` and `ALTER TABLE`.
///
///     conn.create(table: Planet.self)
///         .column(for: \.name, type: .text, .notNull)
///         .run()
///
/// See `SQLCreateTableBuilder` and `SQLAlterTableBuilder` for more information.
public protocol SQLColumnBuilder: SQLQueryBuilder {
    /// See `SQLColumnDefinition`.
    associatedtype ColumnDefinition: SQLColumnDefinition
    
    /// Columns to create.
    var columns: [ColumnDefinition] { get set }
}

extension SQLColumnBuilder {
    /// Adds a column to the table.
    ///
    ///     conn.create(table: Planet.self).column(for: \.name, type: .text, .notNull).run()
    ///
    /// - parameters:
    ///     - keyPath: Swift `KeyPath` to property that should be added.
    ///     - type: Name of type to use for this column.
    ///     - constraints: Zero or more column constraints to add.
    /// - returns: Self for chaining.
    public func column<T, V>(
        for keyPath: KeyPath<T, V?>,
        _ constraints: ColumnDefinition.ColumnConstraint...
    ) -> Self where T: SQLTable {
        guard let dataType = ColumnDefinition.DataType.dataType(appropriateFor: V.self) else {
            assertionFailure("No known \(Connectable.Connection.Query.CreateTable.ColumnDefinition.DataType.self) for \(V.self).")
            return self
        }
        return column(.columnDefinition(.keyPath(keyPath), dataType, constraints))
    }
    
    /// Adds a column to the table.
    ///
    ///     conn.create(table: Planet.self).column(for: \.name, type: .text, .notNull).run()
    ///
    /// - parameters:
    ///     - keyPath: Swift `KeyPath` to property that should be added.
    ///     - type: Name of type to use for this column.
    ///     - constraints: Zero or more column constraints to add.
    /// - returns: Self for chaining.
    public func column<T, V>(
        for keyPath: KeyPath<T, V>,
        _ constraints: ColumnDefinition.ColumnConstraint...
    ) -> Self where T: SQLTable {
        guard let dataType = ColumnDefinition.DataType.dataType(appropriateFor: V.self) else {
            assertionFailure("No known \(Connectable.Connection.Query.CreateTable.ColumnDefinition.DataType.self) for \(V.self).")
            return self
        }
        return column(.columnDefinition(.keyPath(keyPath), dataType, [.notNull] + constraints))
    }
    
    /// Adds a column to the table.
    ///
    ///     conn.create(table: Planet.self).column(for: \.name, type: .text, .notNull).run()
    ///
    /// - parameters:
    ///     - keyPath: Swift `KeyPath` to property that should be added.
    ///     - type: Name of type to use for this column.
    ///     - constraints: Zero or more column constraints to add.
    /// - returns: Self for chaining.
    public func column<T, V>(
        for keyPath: KeyPath<T, V>,
        type dataType: ColumnDefinition.DataType,
        _ constraints: ColumnDefinition.ColumnConstraint...
        ) -> Self where T: SQLTable {
        return column(.columnDefinition(.keyPath(keyPath), dataType, constraints))
    }
    
    /// Adds a column to the table.
    ///
    ///     conn.create(table: Planet.self).column(...).run()
    ///
    /// - parameters:
    ///     - columnDefinition: Column definition to add.
    /// - returns: Self for chaining.
    public func column(_ columnDefinition: ColumnDefinition) -> Self {
        columns.append(columnDefinition)
        return self
    }
}
