/// `UPDATE` statement.
///
/// See `SQLUpdateBuilder`.
public struct SQLUpdate: SQLExpression {
    /// Table to update.
    public var table: SQLIdentifier
    
    /// Zero or more identifier: expression pairs to update.
    public var values: [SQLExpression]
    
    /// Optional predicate to limit updated rows.
    public var predicate: SQLExpression?
    
    /// Creates a new `SQLUpdate`.
    public init(table: SQLIdentifier) {
        self.table = table
        self.values = []
        self.predicate = nil
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write("UPDATE ")
        self.table.serialize(to: &serializer)
        serializer.write(" SET ")
        self.values.serialize(to: &serializer, joinedBy: ", ")
        if let predicate = self.predicate {
            serializer.write(" WHERE ")
            predicate.serialize(to: &serializer)
        }
    }
}
