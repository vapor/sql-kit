/// `FOREIGN KEY` clause.
public struct SQLForeignKey: SQLExpression {
    public let table: any SQLExpression
    
    public let columns: [any SQLExpression]
    
    public let onDelete: (any SQLExpression)?
    
    public let onUpdate: (any SQLExpression)?
    
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
