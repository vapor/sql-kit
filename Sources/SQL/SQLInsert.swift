/// `INSERT INTO ...` statement.
///
/// See `SQLInsertBuilder`.
public protocol SQLInsert: SQLSerializable {
    /// See `SQLTableIdentifier`.
    associatedtype TableIdentifier: SQLTableIdentifier
    
    /// See `SQLColumnIdentifier`.
    associatedtype ColumnIdentifier: SQLColumnIdentifier
    
    /// See `SQLExpression`.
    associatedtype Expression: SQLExpression

    /// Creates a new `SQLInsert`.
    static func insert(_ table: TableIdentifier) -> Self
    
    /// Array of column identifiers to insert values for.
    var columns: [ColumnIdentifier] { get set }
    
    /// Two-dimensional array of values to insert. The count of each nested array _must_
    /// be equal to the count of `columns`.
    ///
    /// Use the `DEFAULT` literal to omit a value and that is specified as a column.
    var values: [[Expression]] { get set }
}

// MARK: Generic

/// Generic implementation of `SQLInsert`.
public struct GenericSQLInsert<TableIdentifier, ColumnIdentifier, Expression>: SQLInsert
    where TableIdentifier: SQLTableIdentifier, ColumnIdentifier: SQLColumnIdentifier, Expression: SQLExpression
{
    /// Convenience alias for self.
    public typealias `Self` = GenericSQLInsert<TableIdentifier, ColumnIdentifier, Expression>
    
    /// See `SQLInsert`.
    public static func insert(_ table: TableIdentifier) -> Self {
        return .init(table: table, columns: [], values: [])
    }
    
    /// See `SQLInsert`.
    public var table: TableIdentifier
    
    /// See `SQLInsert`.
    public var columns: [ColumnIdentifier]
    
    /// See `SQLInsert`.
    public var values: [[Expression]]
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append("INSERT INTO")
        sql.append(table.serialize(&binds))
        sql.append("(" + columns.serialize(&binds) + ")")
        sql.append("VALUES")
        sql.append(values.map { "(" + $0.serialize(&binds) + ")"}.joined(separator: ", "))
        return sql.joined(separator: " ")
    }
}
