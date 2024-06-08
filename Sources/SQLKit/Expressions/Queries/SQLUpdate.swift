/// An expression representing an `UPDATE` query. Used to modify existing rows in a single table.
///
/// ```sql
/// UPDATE "table" SET
///     "column1"=$0,
///     "column2"=$1
/// WHERE
///     "column3"!=$2
/// RETURNING
///     "id"
/// ;
/// ```
///
/// Because of the radically different syntax required for "multi-table" updates between dialects, additional dialect
/// support would be required to implement this functionality; this is planned for the next major update to SQLKit.
///
/// See ``SQLUpdateBuilder``.
public struct SQLUpdate: SQLExpression {
    /// An optional common table expression group.
    public var tableExpressionGroup: SQLCommonTableExpressionGroup?
    
    /// The table containing the row(s) to be updated.
    public var table: any SQLExpression
    
    /// One or more column assignment expressions describing how to update the value in each affected row.
    ///
    /// See ``SQLColumnAssignment`` and ``SQLColumnUpdateBuilder``.
    public var values: [any SQLExpression] = []
    
    /// If not `nil`, a predicate which describes the row(s) to be updated.
    ///
    /// If no predicate if given, all rows in the table are implicitly eligible for updating.
    public var predicate: (any SQLExpression)? = nil

    /// An optional ``SQLReturning`` clause specifying data to return from the updated rows.
    public var returning: SQLReturning? = nil
    
    /// Create a new row modification query.
    ///
    /// - Parameter table: The table containing the row(s) to update.
    @inlinable
    public init(table: any SQLExpression) {
        self.table = table
    }
    
    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append(self.tableExpressionGroup)
            $0.append("UPDATE", self.table)
            $0.append("SET", SQLList(self.values))
            if let predicate = self.predicate {
                $0.append("WHERE", predicate)
            }
            $0.append(self.returning)
        }
    }
}
