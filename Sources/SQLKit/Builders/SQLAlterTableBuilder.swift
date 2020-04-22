public final class SQLAlterTableBuilder: SQLQueryBuilder {
    /// `SQLAlterTable` query being built.
    public var alterTable: SQLAlterTable

    public var database: SQLDatabase

    public var query: SQLExpression {
        return self.alterTable
    }

    public var columns: [SQLExpression] {
        get { return alterTable.addColumns }
        set { alterTable.addColumns = newValue }
    }

    /// Creates a new `SQLAlterTableBuilder`.
    public init(_ alterTable: SQLAlterTable, on database: SQLDatabase) {
        self.alterTable = alterTable
        self.database = database
    }

    public func column(
        _ column: String,
        type dataType: SQLDataType,
        _ constraints: SQLColumnConstraintAlgorithm...
    ) -> Self {
        return self.addColumn(SQLColumnDefinition(
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
        return self.addColumn(SQLColumnDefinition(
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
        return self.addColumn(SQLColumnDefinition(
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
        return self.addColumn(SQLColumnDefinition(
            column: column,
            dataType: dataType,
            constraints: constraints
        ))
    }

    public func addColumn(_ columnDefinition: SQLExpression) -> Self {
        self.alterTable.addColumns.append(columnDefinition)
        return self
    }

    public func modifyColumn(
        _ column: String,
        type dataType: SQLDataType,
        _ constraints: SQLColumnConstraintAlgorithm...
    ) -> Self {
        return self.modifyColumn(SQLColumnDefinition(
            column: SQLIdentifier(column),
            dataType: dataType,
            constraints: constraints
        ))
    }

    public func modifyColumn(
        _ column: String,
        type dataType: SQLDataType,
        _ constraints: [SQLColumnConstraintAlgorithm]
    ) -> Self {
        return self.modifyColumn(SQLColumnDefinition(
            column: SQLIdentifier(column),
            dataType: dataType,
            constraints: constraints
        ))
    }

    public func modifyColumn(
        _ column: SQLExpression,
        type dataType: SQLExpression,
        _ constraints: SQLExpression...
    ) -> Self {
        return self.modifyColumn(SQLColumnDefinition(
            column: column,
            dataType: dataType,
            constraints: constraints
        ))
    }

    public func modifyColumn(
        _ column: SQLExpression,
        type dataType: SQLExpression,
        _ constraints: [SQLExpression]
    ) -> Self {
        return self.modifyColumn(SQLColumnDefinition(
            column: column,
            dataType: dataType,
            constraints: constraints
        ))
    }

    public func update(
        column: String,
        type dataType: SQLDataType
    ) -> Self {
        self.modifyColumn(SQLAlterColumnDefinitionType(
            column: SQLIdentifier(column),
            dataType: dataType
        ))
    }

    public func update(
        column: SQLExpression,
        type dataType: SQLExpression
    ) -> Self {
        self.modifyColumn(SQLAlterColumnDefinitionType(
            column: column,
            dataType: dataType
        ))
    }

    public func modifyColumn(_ columnDefinition: SQLExpression) -> Self {
        self.alterTable.modifyColumns.append(columnDefinition)
        return self
    }

    public func dropColumn(
        _ column: String
    ) -> Self {
        return self.dropColumn(SQLIdentifier(column))
    }

    public func dropColumn(
        _ column: SQLExpression
    ) -> Self {
        self.alterTable.dropColumns.append(column)
        return self
    }

}

// MARK: Connection

extension SQLDatabase {
    /// Creates a new `SQLAlterTableBuilder`.
    ///
    ///     db.alter(table: "planets")...
    ///
    /// - parameters:
    ///     - table: Table to alter.
    /// - returns: `AlterTableBuilder`.
    public func alter(table: String) -> SQLAlterTableBuilder {
        return self.alter(table: SQLIdentifier(table))
    }
    
    /// Creates a new `SQLAlterTableBuilder`.
    ///
    /// - parameters:
    ///     - table: Table to alter.
    /// - returns: `AlterTableBuilder`.
    public func alter(table: SQLIdentifier) -> SQLAlterTableBuilder {
        return .init(.init(name: table), on: self)
    }
}
