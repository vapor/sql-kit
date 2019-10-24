/// Builds data-definition queries that support creating columns, i.e., `CREATE TABLE` and `ALTER TABLE`.
///
///     conn.create(table: "planets")
///         .column(for: "name", type: .text, .notNull)
///         .run()
///
/// See `SQLCreateTableBuilder` and `SQLAlterTableBuilder` for more information.
public protocol SQLColumnBuilder: SQLQueryBuilder {
    /// Columns to create.
    var columns: [SQLExpression] { get set }
}

extension SQLColumnBuilder {
    public func column(
        _ column: String,
        type dataType: SQLDataType,
        _ constraints: SQLColumnConstraintAlgorithm...
    ) -> Self {
        return self.column(SQLColumnDefinition(
            column: SQLIdentifier(column),
            dataType: dataType,
            constraints: constraints
        ))
    }
    
    public func column(
        _ column: SQLExpression,
        type dataType: SQLExpression,
        _ constraints: SQLExpression...
    ) -> Self {
        return self.column(SQLColumnDefinition(
            column: column,
            dataType: dataType,
            constraints: constraints
        ))
    }
    
    public func column(_ columnDefinition: SQLExpression) -> Self {
        self.columns.append(columnDefinition)
        return self
    }
}
