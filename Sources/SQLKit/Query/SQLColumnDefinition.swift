/// Table column definition. DDL. Used by `SQLCreateTable` and `SQLAlterTable`.
///
/// See `SQLCreateTableBuilder` and `SQLAlterTableBuilder`.
public struct SQLColumnDefinition: SQLExpression {
    public var column: SQLExpression
    
    public var dataType: SQLExpression
    
    public var constraints: [SQLExpression]
    
    /// Creates a new `SQLColumnDefinition` from column identifier, data type, and zero or more constraints.
    public init(column: SQLExpression, dataType: SQLExpression, constraints: [SQLExpression] = []) {
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
    /// ```swift
    /// SQLColumnDefinition(
    ///     column: SQLIdentifier("id"),
    ///     dataType: SQLDataType.bigInt,
    ///     constraints: [SQLColumnConstraintAlgorithm.primaryKey, SQLColumnConstraintAlgorithm.notNull]
    /// )
    /// ```
    /// into this:
    ///
    /// `SQLColumnDefinition("id", dataType: .bigint, constraints: [.primaryKey, .notNull]`
    public init(_ name: String, dataType: SQLDataType, constraints: [SQLColumnConstraintAlgorithm] = []) {
        self.init(column: SQLIdentifier(name), dataType: dataType, constraints: constraints)
    }
}
