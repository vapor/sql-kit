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
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write("REFERENCES ")
        self.table.serialize(to: &serializer)
        serializer.write(" ")
        SQLGroupExpression(self.columns).serialize(to: &serializer)

        if let onDelete = self.onDelete {
            serializer.write(" ON DELETE ")
            onDelete.serialize(to: &serializer)
        }
        if let onUpdate = self.onUpdate {
            serializer.write(" ON UPDATE ")
            onUpdate.serialize(to: &serializer)
        }
    }
}
