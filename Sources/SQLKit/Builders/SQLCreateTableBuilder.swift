/// Builds `SQLCreateTable` queries.
///
///    db.create(table: Planet.self).ifNotExists()
///        .column(for: \Planet.id, .primaryKey)
///        .column(for: \Planet.galaxyID, .references(\Galaxy.id))
///        .run()
///
/// See `SQLColumnBuilder` and `SQLQueryBuilder` for more information.
public final class SQLCreateTableBuilder: SQLQueryBuilder {
    /// `CreateTable` query being built.
    public var createTable: SQLCreateTable
    
    public var database: SQLDatabase

    public var query: SQLExpression {
        return self.createTable
    }

    public var columns: [SQLExpression] {
        get { return createTable.columns }
        set { createTable.columns = newValue }
    }
    
    /// Creates a new `SQLCreateTableBuilder`.
    public init(_ createTable: SQLCreateTable, on database: SQLDatabase) {
        self.createTable = createTable
        self.database = database
    }

    public func column(
        _ column: String,
        type dataType: SQLDataType,
        _ constraints: SQLColumnConstraintAlgorithm...
    ) -> Self {
        return self.column(SQLColumnDefinition(
            column: SQLIdentifier(column),
            dataType: dataType,
            constraints: constraints
        ))
    }

    public func column(
        _ column: String,
        type dataType: SQLDataType,
        _ constraints: [SQLColumnConstraintAlgorithm]
    ) -> Self {
        return self.column(SQLColumnDefinition(
            column: SQLIdentifier(column),
            dataType: dataType,
            constraints: constraints
        ))
    }

    public func column(
        _ column: SQLExpression,
        type dataType: SQLExpression,
        _ constraints: SQLExpression...
    ) -> Self {
        return self.column(SQLColumnDefinition(
            column: column,
            dataType: dataType,
            constraints: constraints
        ))
    }

    public func column(
        _ column: SQLExpression,
        type dataType: SQLExpression,
        _ constraints: [SQLExpression]
    ) -> Self {
        return self.column(SQLColumnDefinition(
            column: column,
            dataType: dataType,
            constraints: constraints
        ))
    }

    public func column(_ columnDefinition: SQLExpression) -> Self {
        self.columns.append(columnDefinition)
        return self
    }
    
    /// Sugar for `definitions.forEach { builder.column($0) }`
    public func column(definitions: [SQLColumnDefinition]) -> SQLCreateTableBuilder {
        self.columns.append(contentsOf: definitions)
        return self
    }

    /// If the "TEMP" or "TEMPORARY" keyword occurs between the "CREATE" and "TABLE" then the new table is created in the temp database.
    public func temporary() -> Self {
        createTable.temporary = true
        return self
    }
    
    /// It is usually an error to attempt to create a new table in a database that already contains a table, index or view of the
    /// same name. However, if the "IF NOT EXISTS" clause is specified as part of the CREATE TABLE statement and a table or view
    /// of the same name already exists, the CREATE TABLE command simply has no effect (and no error message is returned). An
    /// error is still returned if the table cannot be created because of an existing index, even if the "IF NOT EXISTS" clause is
    /// specified.
    public func ifNotExists() -> Self {
        createTable.ifNotExists = true
        return self
    }
}

// MARK: Constraints

extension SQLCreateTableBuilder {
    /// Adds a new `PRIMARY KEY` constraint to the table being built
    ///
    /// - parameters:
    ///     - columns: One or more  columns of the table currently being built to make into a Primary Key.
    ///     - constraintName: An optional name to give the constraint.
    public func primaryKey(_ columns: String..., named constraintName: String? = nil) -> Self {
        return primaryKey(columns, named: constraintName)
    }

    /// Adds a new `PRIMARY KEY` constraint to the table being built
    ///
    /// - parameters:
    ///     - columns: One or more  columns of the table currently being built to make into a Primary Key.
    ///     - constraintName: An optional name to give the constraint.
    public func primaryKey(_ columns: [String], named constraintName: String? = nil) -> Self {
        return primaryKey(
            columns.map(SQLIdentifier.init(_:)),
            named: constraintName.map(SQLIdentifier.init(_:))
        )
    }

    /// Adds a new `PRIMARY KEY` constraint to the table being built
    ///
    /// - parameters:
    ///     - columns: One or more  columns of the table currently being built to make into a Primary Key.
    ///     - constraintName: An optional name to give the constraint.
    public func primaryKey(_ columns: [SQLExpression], named constraintName: SQLExpression? = nil) -> Self {
        createTable.tableConstraints.append(
            SQLConstraint(
                algorithm: SQLTableConstraintAlgorithm.primaryKey(columns: columns),
                name: constraintName
            )
        )
        return self
    }

    /// Adds a new `UNIQUE` constraint to the table being built
    ///
    /// - parameters:
    ///     - columns: One or more  columns of the table currently being built to make into a UNIQUE constraint.
    ///     - constraintName: An optional name to give the constraint.
    public func unique(_ columns: String..., named constraintName: String? = nil) -> Self {
        return unique(columns, named: constraintName)
    }

    /// Adds a new `UNIQUE` constraint to the table being built
    ///
    /// - parameters:
    ///     - columns: One or more  columns of the table currently being built to make into a UNIQUE constraint.
    ///     - constraintName: An optional name to give the constraint.
    public func unique(_ columns: [String], named constraintName: String? = nil) -> Self {
        return unique(
            columns.map(SQLIdentifier.init(_:)),
            named: constraintName.map(SQLIdentifier.init(_:))
        )
    }

    /// Adds a new `UNIQUE` constraint to the table being built
    ///
    /// - parameters:
    ///     - columns: One or more  columns of the table currently being built to make into a UNIQUE constraint.
    ///     - constraintName: An optional name to give the constraint.
    public func unique(_ columns: [SQLExpression], named constraintName: SQLExpression? = nil) -> Self {
        createTable.tableConstraints.append(
            SQLConstraint(
                algorithm: SQLTableConstraintAlgorithm.unique(columns: columns),
                name: constraintName
            )
        )
        return self
    }

    /// Adds a new `CHECK` constraint to the table being built
    ///
    /// - parameters:
    ///     - expression: A check constraint expression.
    ///     - constraintName: An optional name to give the constraint.
    public func check(_ expression: SQLExpression, named constraintName: String? = nil) -> Self {
        return self.check(
            expression,
            named: constraintName.map(SQLIdentifier.init(_:))
        )
    }

    /// Adds a new `CHECK` constraint to the table being built
    ///
    /// - parameters:
    ///     - expression: A check constraint expression.
    ///     - constraintName: An optional name to give the constraint.
    public func check(_ expression: SQLExpression, named constraintName: SQLExpression? = nil) -> Self {
        createTable.tableConstraints.append(
            SQLConstraint(
                algorithm: SQLTableConstraintAlgorithm.check(expression),
                name: constraintName
            )
        )
        return self
    }

    /// Adds a new `FOREIGN KEY` constraint to the table being built
    ///
    /// - parameters:
    ///     - columns: One or more columns of the table currently being built to constrain.
    ///     - foreignTable: A table containing a foreign key to be constrained to.
    ///     - foreignColumns: One or more columns of the foreign table to be constrained to.
    ///     - onDelete: Optional foreign key action to perform on delete.
    ///     - onUpdate: Optional foreign key action to perform on update.
    ///     - constraintName: An optional name to give the constraint.
    public func foreignKey(
        _ columns: [String],
        references foreignTable: String,
        _ foreignColumns: [String],
        onDelete: SQLForeignKeyAction? = nil,
        onUpdate: SQLForeignKeyAction? = nil,
        named constraintName: String? = nil
    ) -> Self {
        return self.foreignKey(
            columns.map(SQLIdentifier.init(_:)),
            references: SQLIdentifier(foreignTable),
            foreignColumns.map(SQLIdentifier.init(_:)),
            onDelete: onDelete,
            onUpdate: onUpdate,
            named: constraintName.map(SQLIdentifier.init(_:))
        )
    }

    /// Adds a new `FOREIGN KEY` constraint to the table being built
    ///
    /// - parameters:
    ///     - columns: One or more columns of the table currently being built to constrain.
    ///     - foreignTable: A table containing a foreign key to be constrained to.
    ///     - foreignColumns: One or more columns of the foreign table to be constrained to.
    ///     - onDelete: Optional foreign key action to perform on delete.
    ///     - onUpdate: Optional foreign key action to perform on update.
    ///     - constraintName: An optional name to give the constraint.
    public func foreignKey(
        _ columns: [SQLExpression],
        references foreignTable: SQLExpression,
        _ foreignColumns: [SQLExpression],
        onDelete: SQLExpression? = nil,
        onUpdate: SQLExpression? = nil,
        named constraintName: SQLExpression? = nil
    ) -> Self {
        createTable.tableConstraints.append(
            SQLConstraint(
                algorithm: SQLTableConstraintAlgorithm.foreignKey(
                    columns: columns,
                    references: SQLForeignKey(
                        table: foreignTable,
                        columns: foreignColumns,
                        onDelete: onDelete,
                        onUpdate: onUpdate
                    )
                ),
                name: constraintName
            )
        )
        return self
    }
}

// MARK: Connection

extension SQLDatabase {
    /// Creates a new `SQLCreateTableBuilder`.
    ///
    ///     db.create(table: "planets")...
    ///
    /// - parameters:
    ///     - table: Table to create.
    /// - returns: `CreateTableBuilder`.
    public func create(table: String) -> SQLCreateTableBuilder {
        return self.create(table: SQLIdentifier(table))
    }
    
    /// Creates a new `SQLCreateTableBuilder`.
    ///
    ///     db.create(table: SQLIdentifier("planets"))...
    ///
    /// - parameters:
    ///     - table: Table to create.
    /// - returns: `CreateTableBuilder`.
    public func create(table: SQLExpression) -> SQLCreateTableBuilder {
        return .init(.init(name: table), on: self)
    }
}
