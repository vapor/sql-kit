/// `ALTER TABLE` query.
///
///     db.alter(table: Planet.self)
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
    /// Table constraints, such as `FOREIGN KEY`, to add.
    public var addTableConstraints: [SQLExpression]
    /// Table constraints, such as `FOREIGN KEY`, to delete.
    public var dropTableConstraints: [SQLExpression]
    
    /// Creates a new `SQLAlterTable`. See `SQLAlterTableBuilder`.
    public init(name: SQLExpression) {
        self.name = name
        self.addColumns = []
        self.modifyColumns = []
        self.dropColumns = []
        self.addTableConstraints = []
        self.dropTableConstraints = []
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        let syntax = serializer.dialect.alterTableSyntax

        if !syntax.allowsBatch && self.addColumns.count + self.modifyColumns.count + self.dropColumns.count > 1 {
            serializer.database.logger.warning("Database does not support batch table alterations. You will need to rewrite as individual alter statements.")
        }

        if syntax.alterColumnDefinitionClause == nil && self.modifyColumns.count > 0 {
            serializer.database.logger.warning("Database does not support column modifications. You will need to rewrite as drop and add clauses.")
        }

        let additions = (self.addColumns + self.addTableConstraints).map { column in
            (verb: SQLRaw("ADD"), definition: column)
        }

        let removals = (self.dropColumns + self.dropTableConstraints).map { column in
            (verb: SQLRaw("DROP"), definition: column)
        }

        let alterColumnDefinitionCaluse = syntax.alterColumnDefinitionClause ?? SQLRaw("MODIFY")
        let modifications = self.modifyColumns.map { column in
            (verb: alterColumnDefinitionCaluse, definition: column)
        }

        let alterations = additions + removals + modifications

        serializer.statement {
            $0.append("ALTER TABLE")
            $0.append(self.name)
            for (idx, alteration) in alterations.enumerated() {
                if idx > 0 {
                    $0.append(",")
                }
                $0.append(alteration.verb)
                $0.append(alteration.definition)
            }
        }
    }
}
