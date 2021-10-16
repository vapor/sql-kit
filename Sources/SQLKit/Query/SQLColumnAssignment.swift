/// Encapsulates a `col_name=value` expression in the context of an `UPDATE` query's value
/// assignment list. This is distinct from an `SQLBinaryExpression` using the `.equal`
/// operator in that the left side must be an _unqualified_ column name, the operator must
/// be `=`, and the right side may use `SQLExcludedColumn` when the assignment appears in
/// the `assignments` list of a `SQLConflictAction.update` specification.
public struct SQLColumnAssignment: SQLExpression {
    /// The name of the column to assign.
    public var columnName: SQLExpression
    
    /// The value to assign.
    public var value: SQLExpression
    
    /// Create a column assignment from a column identifier and value expression.
    public init(setting columnName: SQLExpression, to value: SQLExpression) {
        self.columnName = columnName
        self.value = value
    }
    
    /// Create a column assignment from a column identifier and value binding.
    public init(setting columnName: SQLExpression, to value: Encodable) {
        self.init(setting: columnName, to: SQLBind(value))
    }

    /// Create a column assignment from a column name and value binding.
    public init(setting columnName: String, to value: Encodable) {
        self.init(setting: columnName, to: SQLBind(value))
    }

    /// Create a column assignment from a column name and value expression.
    public init(setting columnName: String, to value: SQLExpression) {
        self.init(setting: SQLColumn(columnName), to: value)
    }
    
    /// Create a column assignment from a column name and using the excluded value
    /// from an upsert's values list. See `SQLExcludedColumn`.
    public init(settingExcludedValueFor columnName: String) {
        self.init(settingExcludedValueFor: SQLColumn(columnName))
    }

    /// Create a column assignment from a column identifier and using the excluded value
    /// from an upsert's values list. See `SQLExcludedColumn`.
    public init(settingExcludedValueFor column: SQLExpression) {
        self.init(setting: column, to: SQLExcludedColumn(column))
    }
    
    /// See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        self.columnName.serialize(to: &serializer)
        serializer.write("=") // do not use SQLBinaryOperator.equal, which may be `==` in some dialects
        self.value.serialize(to: &serializer)
    }
}
