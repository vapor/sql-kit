/// A clause specifying a new data type to be applied to an existing column.
///
/// This expression is used by ``SQLAlterTableBuilder/modifyColumn(_:type:_:)-24c9h`` to abstract over the use of
/// ``SQLAlterTableSyntax/alterColumnDefinitionTypeKeyword`` in the dialect's ``SQLDialect/alterTableSyntax-9bmcr``.
/// The serialized SQL is of the form:
///
/// ```sql
/// column alterColumnDefinitionTypeKeyword dataType
/// -- Given column == SQLIdentifier("col"), dataType == SQLDataTyoe.text:
/// -- PostgreSQL: "col" SET DATA TYPE TEXT
/// --      MySQL: `col` TEXT
/// ```
///
/// Users should not use this expression. It is an oversight that it is public API; it will eventually be removed.
public struct SQLAlterColumnDefinitionType: SQLExpression {
    /// The column to alter.
    public var column: any SQLExpression
    
    /// The new data type.
    public var dataType: any SQLExpression

    /// Create a new ``SQLAlterColumnDefinitionType`` expression.
    ///
    /// - Parameters:
    ///   - column: The column to alter.
    ///   - dataType: The new data type.
    @inlinable
    public init(column: SQLIdentifier, dataType: SQLDataType) {
        self.column = column
        self.dataType = dataType
    }

    /// Create a new ``SQLAlterColumnDefinitionType`` expression.
    ///
    /// - Parameters:
    ///   - column: The column to alter.
    ///   - dataType: The new data type.
    @inlinable
    public init(column: any SQLExpression, dataType: any SQLExpression) {
        self.column = column
        self.dataType = dataType
    }

    // See `SQLExpression.serialize(to:)`.
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
