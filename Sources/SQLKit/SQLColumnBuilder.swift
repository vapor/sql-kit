/// Builds data-definition queries that support creating columns, i.e., `CREATE TABLE` and `ALTER TABLE`.
///
///     conn.create(table: Planet.self)
///         .column(for: \.name, type: .text, .notNull)
///         .run()
///
/// See `SQLCreateTableBuilder` and `SQLAlterTableBuilder` for more information.
public protocol SQLColumnBuilder: SQLQueryBuilder {
    /// See `SQLColumnDefinition`.
    associatedtype ColumnDefinition: SQLColumnDefinition
    
    /// Columns to create.
    var columns: [ColumnDefinition] { get set }
}

extension SQLColumnBuilder {
    public func column(
        _ column: ColumnDefinition.ColumnIdentifier,
        type dataType: ColumnDefinition.DataType,
        _ constraints: ColumnDefinition.ColumnConstraint...
    ) -> Self {
        return self.column(.columnDefinition(column, dataType, constraints))
    }
    
    public func column(_ columnDefinition: ColumnDefinition) -> Self {
        self.columns.append(columnDefinition)
        return self
    }
}
