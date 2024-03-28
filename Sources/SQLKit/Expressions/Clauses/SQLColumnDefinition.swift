/// A clause expressing a column definition, for use when creating and altering tables.
///
/// See ``SQLCreateTable``, ``SQLCreateTableBuilder``, ``SQLAlterTable``, and ``SQLAlterTableBuilder``.
public struct SQLColumnDefinition: SQLExpression {
    /// The name of the column to create or alter.
    public var column: any SQLExpression
    
    /// The desired data type of the column.
    ///
    /// Usually valid only when creating a table. When altering an existing column, ``SQLAlterColumnDefinitionType``
    /// should be used to ensure correct behavior between dialects.
    public var dataType: any SQLExpression
    
    /// A list of column-level constraints to apply to the column.
    ///
    /// See ``SQLColumnConstraintAlgorithm``. Do not add table-level constraints to this list.
    public var constraints: [any SQLExpression]
    
    /// Create a new columm definition from a name, data type, and zero or more constraints.
    ///
    /// - Parameters:
    ///   - column: The column name to create or alter.
    ///   - dataType: The desired data type of the column.
    ///   - constraints: The constraints to apply to the column, if any.
    @inlinable
    public init(
        column: any SQLExpression,
        dataType: any SQLExpression,
        constraints: [any SQLExpression] = []
    ) {
        self.column = column
        self.dataType = dataType
        self.constraints = constraints
    }
    
    /// Create a new columm definition from a name, data type, and zero or more constraints.
    ///
    /// - Parameters:
    ///   - column: The column name to create or alter.
    ///   - dataType: The desired data type of the column.
    ///   - constraints: The constraints to apply to the column, if any.
    @inlinable
    public init(
        _ name: String,
        dataType: SQLDataType,
        constraints: [SQLColumnConstraintAlgorithm] = []
    ) {
        self.init(column: SQLIdentifier(name), dataType: dataType, constraints: constraints)
    }

    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append(self.column, self.dataType)
            if !self.constraints.isEmpty {
                $0.append(SQLList(self.constraints, separator: SQLRaw(" ")))
            }
        }
    }
}
