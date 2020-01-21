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
    /// Columns to add.
    public var modifyColumns: [SQLExpression]
    
    /// Creates a new `SQLAlterTable`. See `SQLAlterTableBuilder`.
    public init(name: SQLExpression) {
        self.name = name
        self.addColumns = []
        self.modifyColumns = []
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write("ALTER TABLE ")
        self.name.serialize(to: &serializer)
        for column in self.addColumns {
            serializer.write(" ADD ")
            column.serialize(to: &serializer)
        }
        for column in self.modifyColumns {
            serializer.write(" MODIFY ")
            column.serialize(to: &serializer)
        }
    }
}
