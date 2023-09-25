/// Builds ``SQLAlterTable`` queries.
public final class SQLAlterTableBuilder: SQLQueryBuilder {
    /// ``SQLAlterTable`` query being built.
    public var alterTable: SQLAlterTable

    /// See ``SQLQueryBuilder/database``.
    public var database: any SQLDatabase

    /// See ``SQLQueryBuilder/query``.
    @inlinable
    public var query: any SQLExpression {
        self.alterTable
    }

    /// The set of column alteration expressions.
    @inlinable
    public var columns: [any SQLExpression] {
        get { self.alterTable.addColumns }
        set { self.alterTable.addColumns = newValue }
    }

    /// Create a new ``SQLAlterTableBuilder``.
    @inlinable
    public init(_ alterTable: SQLAlterTable, on database: any SQLDatabase) {
        self.alterTable = alterTable
        self.database = database
    }
    
    /// Rename the table.
    @inlinable
    @discardableResult
    public func rename(to newName: String) -> Self {
        self.rename(to: SQLIdentifier(newName))
    }
    
    /// Rename the table.
    @inlinable
    @discardableResult
    public func rename(to newName: any SQLExpression) -> Self {
        self.alterTable.renameTo = newName
        return self
    }
    
    /// Add a new column to the table.
    @inlinable
    @discardableResult
    public func column(_ column: String, type dataType: SQLDataType, _ constraints: SQLColumnConstraintAlgorithm...) -> Self {
        self.column(column, type: dataType, constraints)
    }
    
    /// Add a new column to the table.
    @inlinable
    @discardableResult
    public func column(_ column: String, type dataType: SQLDataType, _ constraints: [SQLColumnConstraintAlgorithm]) -> Self {
        self.column(SQLIdentifier(column), type: dataType, constraints)
    }
    
    /// Add a new column to the table.
    @inlinable
    @discardableResult
    public func column(_ column: any SQLExpression, type dataType: any SQLExpression, _ constraints: any SQLExpression...) -> Self {
        self.column(column, type: dataType, constraints)
    }
    
    /// Add a new column to the table.
    @inlinable
    @discardableResult
    public func column(_ column: any SQLExpression, type dataType: any SQLExpression, _ constraints: [any SQLExpression]) -> Self {
        self.addColumn(SQLColumnDefinition(column: column, dataType: dataType, constraints: constraints))
    }
    
    /// Add a new column to the table.
    @inlinable
    @discardableResult
    public func addColumn(_ columnDefinition: any SQLExpression) -> Self {
        self.alterTable.addColumns.append(columnDefinition)
        return self
    }
    
    /// Change an existing column's type and constraints.
    @inlinable
    @discardableResult
    public func modifyColumn(_ column: String, type dataType: SQLDataType, _ constraints: SQLColumnConstraintAlgorithm...) -> Self {
        self.modifyColumn(column, type: dataType, constraints)
    }
    
    /// Change an existing column's type and constraints.
    @inlinable
    @discardableResult
    public func modifyColumn(_ column: String, type dataType: SQLDataType, _ constraints: [SQLColumnConstraintAlgorithm]) -> Self {
        self.modifyColumn(SQLIdentifier(column), type: dataType, constraints)
    }
    
    /// Change an existing column's type and constraints.
    @inlinable
    @discardableResult
    public func modifyColumn(_ column: any SQLExpression, type dataType: any SQLExpression, _ constraints: any SQLExpression...) -> Self {
        self.modifyColumn(column, type: dataType, constraints)
    }
    
    /// Change an existing column's type and constraints.
    @inlinable
    @discardableResult
    public func modifyColumn(_ column: any SQLExpression, type dataType: any SQLExpression, _ constraints: [any SQLExpression]) -> Self {
        self.modifyColumn(SQLColumnDefinition(column: column, dataType: dataType, constraints: constraints))
    }
    
    /// Change an existing column's type.
    @inlinable
    @discardableResult
    public func update(column: String, type dataType: SQLDataType) -> Self {
        self.update(column: SQLIdentifier(column), type: dataType)
    }
    
    /// Change an existing column's type.
    @inlinable
    @discardableResult
    public func update(column: any SQLExpression, type dataType: any SQLExpression) -> Self {
        self.modifyColumn(SQLAlterColumnDefinitionType(column: column, dataType: dataType))
    }
    
    /// Alter an existing column.
    @inlinable
    @discardableResult
    public func modifyColumn(_ columnDefinition: any SQLExpression) -> Self {
        self.alterTable.modifyColumns.append(columnDefinition)
        return self
    }
    
    /// Drop an existing column from the table
    @inlinable
    @discardableResult
    public func dropColumn(_ column: String) -> Self {
        self.dropColumn(SQLIdentifier(column))
    }
    
    /// Drop an existing column from the table
    @inlinable
    @discardableResult
    public func dropColumn(_ column: any SQLExpression) -> Self {
        self.alterTable.dropColumns.append(column)
        return self
    }
}

extension SQLDatabase {
    /// Create a new ``SQLAlterTableBuilder``.
    @inlinable
    public func alter(table: String) -> SQLAlterTableBuilder {
        self.alter(table: SQLIdentifier(table))
    }
    
    /// Create a new ``SQLAlterTableBuilder``.
    @inlinable
    public func alter(table: SQLIdentifier) -> SQLAlterTableBuilder {
         .init(.init(name: table), on: self)
    }
}
