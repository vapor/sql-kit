/// A complete `FOREIGN KEY` constraint specification.
///
/// Does not include the constraint name (if any); see ``SQLConstraint``.
public struct SQLForeignKey: SQLExpression {
    /// The table referenced by the foreign key.
    public let table: any SQLExpression
    
    /// The key column or columns referenced by the foreign key.
    ///
    /// At least one column must be specified.
    public let columns: [any SQLExpression]
    
    /// An action to take when one or more referenced rows are deleted from the referenced table.
    public let onDelete: (any SQLExpression)?
    
    /// An action to take when one or more referenced rows are updated in the referenced table.
    public let onUpdate: (any SQLExpression)?
    
    /// Create a foreign key specification.
    ///
    /// - Parameters:
    ///   - table: The table to reference.
    ///   - columns: One or more columns to reference.
    ///   - onDelete: An optional action to take when referenced rows are deleted.
    ///   - onUpdate: An optional action to take when referenced rows are updated.
    @inlinable
    public init(
        table: any SQLExpression,
        columns: [any SQLExpression],
        onDelete: (any SQLExpression)?,
        onUpdate: (any SQLExpression)?
    ) {
        self.table = table
        self.columns = columns
        self.onDelete = onDelete
        self.onUpdate = onUpdate
    }
    
    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("REFERENCES", self.table, SQLGroupExpression(self.columns))
            if let onDelete = self.onDelete {
                $0.append("ON DELETE", onDelete)
            }
            if let onUpdate = self.onUpdate {
                $0.append("ON UPDATE", onUpdate)
            }
        }
    }
}
