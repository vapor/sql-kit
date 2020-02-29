/// Alters the data type of an existing column.
///
///     column [alterColumnDefinitionTypeClause] dataType
///
public struct SQLAlterColumnDefinitionType: SQLExpression {
    public var column: SQLExpression
    public var dataType: SQLExpression

    public init(column: SQLIdentifier, dataType: SQLDataType) {
        self.column = column
        self.dataType = dataType
    }

    public init(column: SQLExpression, dataType: SQLExpression) {
        self.column = column
        self.dataType = dataType
    }

    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append(self.column)
            if let clause = $0.dialect.alterTableSyntax.alterColumnDefinitionTypeKeyword {
                $0.append(clause)
            }
            $0.append(self.dataType)
        }
    }
}
