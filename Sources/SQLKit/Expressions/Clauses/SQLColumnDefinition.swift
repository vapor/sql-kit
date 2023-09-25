/// Table column definition. DDL. Used by ``SQLCreateTable`` and ``SQLAlterTable``.
///
/// See ``SQLCreateTableBuilder`` and ``SQLAlterTableBuilder``.
public struct SQLColumnDefinition: SQLExpression {
    public var column: any SQLExpression
    
    public var dataType: any SQLExpression
    
    public var constraints: [any SQLExpression]
    
    /// Creates a new ``SQLColumnDefinition`` from column identifier, data type, and zero or more constraints.
    @inlinable
    public init(column: any SQLExpression, dataType: any SQLExpression, constraints: [any SQLExpression] = []) {
        self.column = column
        self.dataType = dataType
        self.constraints = constraints
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        self.column.serialize(to: &serializer)
        serializer.write(" ")
        self.dataType.serialize(to: &serializer)
        if !self.constraints.isEmpty {
            serializer.write(" ")
            SQLList(self.constraints, separator: SQLRaw(" ")).serialize(to: &serializer)
        }
    }
}

extension SQLColumnDefinition {
    /// Create a new column definition from a string, data type, and array of constraints.
    ///
    /// Turns this:
    ///
    ///     SQLColumnDefinition(
    ///         column: SQLIdentifier("id"),
    ///         dataType: SQLDataType.bigInt,
    ///         constraints: [SQLColumnConstraintAlgorithm.primaryKey, SQLColumnConstraintAlgorithm.notNull]
    ///     )
    ///
    /// into this:
    ///
    ///     SQLColumnDefinition("id", dataType: .bigint, constraints: [.primaryKey, .notNull])
    @inlinable
    public init(_ name: String, dataType: SQLDataType, constraints: [SQLColumnConstraintAlgorithm] = []) {
        self.init(column: SQLIdentifier(name), dataType: dataType, constraints: constraints)
    }
}
