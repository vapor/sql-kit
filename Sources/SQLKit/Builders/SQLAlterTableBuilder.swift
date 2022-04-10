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
    
    @discardableResult
    /// Rename the table.
    /// - Parameter newName: The new name to apply to the table
    /// - Returns: `self` for chaining.
    public func rename(
        to newName: String
    ) -> Self {
        return self.rename(to: SQLIdentifier(newName))
    }
    
    @discardableResult
    /// Rename the table.
    /// - Parameter newName: The new name to apply to the table
    /// - Returns: `self` for chaining.
    public func rename(
        to newName: SQLExpression
    ) -> Self {
        self.alterTable.renameTo = newName
        return self
    }
    
    @discardableResult
    /// Add a column to the table.
    /// - Parameters:
    ///   - column: The name of the new column
    ///   - dataType: The new datatype of the new column
    ///   - constraints: Constraints for the new column
    /// - Returns: `self` for chaining.
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
    
    @discardableResult
    /// Add a column to the table.
    /// - Parameters:
    ///   - column: The name of the new column
    ///   - dataType: The new datatype of the new column
    ///   - constraints: Constraints for the new column
    /// - Returns: `self` for chaining.
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
    
    @discardableResult
    /// Add a column to the table.
    /// - Parameters:
    ///   - column: The name of the new column
    ///   - dataType: The new datatype of the new column
    ///   - constraints: Constraints for the new column
    /// - Returns: `self` for chaining.
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
    
    @discardableResult
    /// Add a column to the table.
    /// - Parameters:
    ///   - column: The name of the new column
    ///   - dataType: The new datatype of the new column
    ///   - constraints: Constraints for the new column
    /// - Returns: `self` for chaining.
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
    
    @discardableResult
    /// Add a column to the table.
    /// - Parameter columnDefinition: Expression defining the column
    /// - Returns: `self` for chaining.
    public func addColumn(_ columnDefinition: SQLExpression) -> Self {
        self.alterTable.addColumns.append(columnDefinition)
        return self
    }
    
    @discardableResult
    /// Alter a column in the table.
    /// - Parameters:
    ///   - column: The name of the column to alter
    ///   - dataType: The datatype to change the column to
    ///   - constraints: Constraints to apply to the altered column
    /// - Returns: `self` for chaining.
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
    
    @discardableResult
    /// Alter a column in the table.
    /// - Parameters:
    ///   - column: The name of the column to alter
    ///   - dataType: The datatype to change the column to
    ///   - constraints: Constraints to apply to the altered column
    /// - Returns: `self` for chaining.
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
    
    @discardableResult
    /// Alter a column in the table.
    /// - Parameters:
    ///   - column: The name of the column to alter
    ///   - dataType: The datatype to change the column to
    ///   - constraints: Constraints to apply to the altered column
    /// - Returns: `self` for chaining.
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
    
    @discardableResult
    /// Alter a column in the table.
    /// - Parameters:
    ///   - column: The name of the column to alter
    ///   - dataType: The datatype to change the column to
    ///   - constraints: Constraints to apply to the altered column
    /// - Returns: `self` for chaining.
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
    
    @discardableResult
    /// Alter a column in the table.
    /// - Parameters:
    ///   - column: The name of the column to alter
    ///   - dataType: The datatype to change the column to
    /// - Returns: `self` for chaining.
    public func update(
        column: String,
        type dataType: SQLDataType
    ) -> Self {
        self.modifyColumn(SQLAlterColumnDefinitionType(
            column: SQLIdentifier(column),
            dataType: dataType
        ))
    }
    
    @discardableResult
    /// Alter a column in the table.
    /// - Parameters:
    ///   - column: The name of the column to alter
    ///   - dataType: The datatype to change the column to
    /// - Returns: `self` for chaining.
    public func update(
        column: SQLExpression,
        type dataType: SQLExpression
    ) -> Self {
        self.modifyColumn(SQLAlterColumnDefinitionType(
            column: column,
            dataType: dataType
        ))
    }
    
    @discardableResult
    /// Alter a column in the table.
    /// - Parameter columnDefinition: Expression defining the column changes
    /// - Returns: `self` for chaining.
    public func modifyColumn(_ columnDefinition: SQLExpression) -> Self {
        self.alterTable.modifyColumns.append(columnDefinition)
        return self
    }
    
    @discardableResult
    /// Drop the column from the table
    /// - Parameter column: The name of the column to drop
    /// - Returns: `self` for chaining.
    public func dropColumn(
        _ column: String
    ) -> Self {
        return self.dropColumn(SQLIdentifier(column))
    }
    
    @discardableResult
    /// Drop the column from the table
    /// - Parameter column: The name of the column to drop
    /// - Returns: `self` for chaining.
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
