/// `INSERT INTO ...` statement.
///
/// See `SQLInsertBuilder`.
public struct SQLInsert: SQLExpression {
    public var table: SQLExpression
    
    /// Array of column identifiers to insert values for.
    public var columns: [SQLExpression]
    
    /// Two-dimensional array of values to insert. The count of each nested array _must_
    /// be equal to the count of `columns`.
    ///
    /// Use the `DEFAULT` literal to omit a value and that is specified as a column.
    public var values: [[SQLExpression]]

    public var returning: SQLReturning?
    
    /// Creates a new `SQLInsert`.
    public init(table: SQLExpression) {
        self.table = table
        self.columns = []
        self.values = []
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write("INSERT INTO ")
        self.table.serialize(to: &serializer)
        serializer.write(" ")
        SQLGroupExpression(self.columns).serialize(to: &serializer)
        serializer.write(" VALUES ")
        SQLList(self.values.map(SQLGroupExpression.init)).serialize(to: &serializer)
        returning?.serialize(to: &serializer)
    }
}
