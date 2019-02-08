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
            SQLList(self.constraints).serialize(to: &serializer)
        }
    }
}
