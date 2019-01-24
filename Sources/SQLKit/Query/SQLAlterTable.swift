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
    public var columns: [SQLExpression]
    
    /// Creates a new `SQLAlterTable`. See `SQLAlterTableBuilder`.
    public init(name: SQLExpression) {
        self.name = name
        self.columns = []
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write("ALTER TABLE ")
        self.name.serialize(to: &serializer)
        serializer.write(" ")
        self.columns.serialize(to: &serializer, joinedBy: ", ")
    }
}
