/// `ALTER TABLE` query.
///
///     conn.alter(table: Planet.self)
///         .column(for: \.name)
///         .run()
///
/// See `SQLAlterTableBuilder` for more information.
public struct SQLAlterTable: SQLExpression {
    public var name: SQLExpression
    /// Columns to add.
    public var addColumns: [SQLExpression]
    /// Columns to update.
    public var modifyColumns: [SQLExpression]
    /// Columns to delete.
    public var dropColumns: [SQLExpression]
    
    /// Creates a new `SQLAlterTable`. See `SQLAlterTableBuilder`.
    public init(name: SQLExpression) {
        self.name = name
        self.addColumns = []
        self.modifyColumns = []
        self.dropColumns = []
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("ALTER TABLE")
            $0.append(self.name)
            for column in self.addColumns {
                $0.append("ADD")
                $0.append(column)
            }
            if let clause = $0.dialect.alterTableSyntax.alterColumnDefinitionClause {
                $0.append(clause)
                for column in self.modifyColumns {
                    $0.append(column)
                }
            }
            for column in self.dropColumns {
                $0.append("DROP")
                $0.append(column)
            }
        }
    }
}
