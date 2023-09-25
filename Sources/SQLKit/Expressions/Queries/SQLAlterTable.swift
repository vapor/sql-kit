/// `ALTER TABLE` query.
///
/// See ``SQLAlterTableBuilder``.
public struct SQLAlterTable: SQLExpression {
    public var name: any SQLExpression
    
    /// New name
    public var renameTo: (any SQLExpression)?
    /// Columns to add.
    public var addColumns: [any SQLExpression]
    /// Columns to update.
    public var modifyColumns: [any SQLExpression]
    /// Columns to delete.
    public var dropColumns: [any SQLExpression]
    /// Table constraints, such as `FOREIGN KEY`, to add.
    public var addTableConstraints: [any SQLExpression]
    /// Table constraints, such as `FOREIGN KEY`, to delete.
    public var dropTableConstraints: [any SQLExpression]
    
    /// Creates a new ``SQLAlterTable``. See ``SQLAlterTableBuilder``.
    @inlinable
    public init(name: any SQLExpression) {
        self.name = name
        self.renameTo = nil
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
            if let renameTo = renameTo {
                $0.append("RENAME TO")
                $0.append(renameTo)
            }
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
