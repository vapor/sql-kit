/// `FOREIGN KEY` clause.
public struct SQLForeignKey: SQLExpression {
    public let table: SQLExpression
    
    public let columns: [SQLExpression]
    
    public let onDelete: SQLExpression?
    
    public let onUpdate: SQLExpression?
    
    public init(
        table: SQLExpression,
        columns: [SQLExpression],
        onDelete: SQLExpression?,
        onUpdate: SQLExpression?
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
