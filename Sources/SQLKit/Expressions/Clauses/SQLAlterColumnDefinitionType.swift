/// Alters the data type of an existing column.
///
///     column [alterColumnDefinitionTypeClause] dataType
///
public struct SQLAlterColumnDefinitionType: SQLExpression {
    public var column: any SQLExpression
    public var dataType: any SQLExpression

    @inlinable
    public init(column: SQLIdentifier, dataType: SQLDataType) {
        self.column = column
        self.dataType = dataType
    }

    @inlinable
    public init(column: any SQLExpression, dataType: any SQLExpression) {
        self.column = column
        self.dataType = dataType
    }

    @inlinable
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
