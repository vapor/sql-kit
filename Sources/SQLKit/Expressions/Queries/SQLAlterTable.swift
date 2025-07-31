/// An expression representing an `ALTER TABLE` query. Used to modify the structure of existing tables.
///
/// This expression is partially dialect-aware and will respect specific settings under ``SQLAlterTableSyntax``.
/// However, it does not handle the caae where a dialect has no table alteration support at all (such as SQLite).
///
/// ```sql
/// ALTER TABLE "name"
///     RENAME TO "new_name"
/// ALTER TABLE "new_name"
///     ADD "column1" BLOB NOT NULL,
///     DROP "column2",
///     ALTER "column3" SET DATA TYPE TEXT
/// ```
///
/// See ``SQLAlterTableBuilder``.
///
/// > Warning: There are numerous table alteration operations possible in various dialects which are not supported
/// > by this expression.
public struct SQLAlterTable: SQLExpression {
    /// The name of the table to alter.
    public var name: any SQLExpression
    
    /// If not `nil`, a new name for the table (rename table operation).
    public var renameTo: (any SQLExpression)? = nil
    
    /// A list of zero or more new column definitions (add column operation).
    public var addColumns: [any SQLExpression] = []
    
    /// A list of zero or more column alteration specifications (modify column operation).
    public var modifyColumns: [any SQLExpression] = []
    
    /// A list of zero or more columns to remove (drop column operation).
    public var dropColumns: [any SQLExpression] = []
    
    /// A list of zero or more new table constraints (add table constraint operation).
    public var addTableConstraints: [any SQLExpression] = []
    
    /// A list of zero or more table constraint names to remove (drop table constraint operation).
    public var dropTableConstraints: [any SQLExpression] = []
    
    /// Create a table alteration query for a given table, with no operations specified to start with.
    @inlinable
    public init(name: any SQLExpression) {
        self.name = name
    }
    
    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        let syntax = serializer.dialect.alterTableSyntax
        
        if !syntax.allowsBatch,
           [self.addColumns, self.modifyColumns, self.dropColumns, self.addTableConstraints, self.dropTableConstraints].map(\.count).reduce(0, +) > 1
        {
            serializer.database.logger.debug("Database does not support multiple table operation per statement; perform multiple queries with one alteration each instead.")
            // Emit the query anyway so the error will propagate when the database rejects it.
        }

        if syntax.alterColumnDefinitionClause == nil, !self.modifyColumns.isEmpty {
            serializer.database.logger.debug("Database does not support column modifications.")
            // Emit the query anyway so the error will propagate when the database rejects it.
        }

        let additions = (self.addColumns  + self.addTableConstraints).map  { (verb: SQLUnsafeRaw("ADD"),  definition: $0) }
        let removals  = (self.dropColumns + self.dropTableConstraints).map { (verb: SQLUnsafeRaw("DROP"), definition: $0) }
        let modifications = self.modifyColumns.map { (verb: syntax.alterColumnDefinitionClause ?? SQLUnsafeRaw("__INVALID__"), definition: $0) }
        let alterations = additions + removals + modifications

        serializer.statement {
            $0.append("ALTER TABLE", self.name)
            if let renameTo = self.renameTo {
                $0.append("RENAME TO", renameTo)
            }
            
            var iter = alterations.makeIterator()
            
            if let firstAlter = iter.next() {
                $0.append(firstAlter.verb, firstAlter.definition)
            }
            while let alteration = iter.next() {
                $0.append(",", alteration.verb, alteration.definition)
            }
        }
    }
}
