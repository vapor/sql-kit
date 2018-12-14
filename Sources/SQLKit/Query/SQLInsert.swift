/// `INSERT INTO ...` statement.
///
/// See `SQLInsertBuilder`.
public protocol SQLInsert: SQLSerializable {
    /// See `SQLTableIdentifier`.
    associatedtype Identifier: SQLIdentifier
    
    /// See `SQLColumnIdentifier`.
    associatedtype ColumnIdentifier: SQLColumnIdentifier
    
    /// See `SQLExpression`.
    associatedtype Expression: SQLExpression

    /// Creates a new `SQLInsert`.
    static func insert(table: Identifier) -> Self
    
    /// Array of column identifiers to insert values for.
    var columns: [ColumnIdentifier] { get set }
    
    /// Two-dimensional array of values to insert. The count of each nested array _must_
    /// be equal to the count of `columns`.
    ///
    /// Use the `DEFAULT` literal to omit a value and that is specified as a column.
    var values: [[Expression]] { get set }
}
