/// An expression representing an `INSERT` query. Used to add new rows to a table.
///
/// ```sql
/// INSERT INTO "table"
///     ("id", "column1", "column2")
/// VALUES
///     (DEFAULT, 'a', 'b'),
///     (DEFAULT, 'c', 'd')
/// ON CONFLICT DO NOTHING
/// RETURNING "id";
///
/// INSERT INTO "table"
///     ("id", "column1", "column2")
/// SELECT
///     NULL as "id",
///     "column1",
///     "column2"
/// FROM "other_table"
/// ON CONFLICT DO UPDATE SET "column1"="excluded"."column1", "column2"="excluded"."column2"
/// RETURNING "id";
/// ```
///
/// See ``SQLInsertBuilder``.
public struct SQLInsert: SQLExpression {
    /// The table to which rows are to be added.
    public var table: any SQLExpression
    
    /// List of one or more columns which specify the ordering and count of the inserted values.
    public var columns: [any SQLExpression] = []
    
    /// An array of arrays providing a list of rows to insert as lists of expressions.
    ///
    /// The outer array can be thought of as a list of rows, with each "row" being a list of values for each column.
    /// In any given "row", the value at a given index corresponds to the column at that same index in ``columns``.
    /// Each "row" must have the same number of elements as every other row, which must also be the same number
    /// elements in ``columns``; if this rule is not followed, invalid SQL is generated. ``SQLLiteral/default`` and/or
    /// ``SQLLiteral/null`` can be used to fill in gaps in a given row as appropriate for the column.
    ///
    /// If ``values`` is not an empty array, it is always used, even if ``valueQuery`` is not `nil`. If ``values`` is
    /// empty and ``valueQuery`` is `nil`, invalid SQL is generated.
    public var values: [[any SQLExpression]] = []
    
    /// If not `nil`, a subquery providing a `SELECT` statement which generates rows to insert.
    ///
    /// This will usually be a instance of ``SQLSelect``. Using ``SQLSubquery`` may result in syntax errors in
    /// some dialects.
    ///
    /// Ignored unless ``values`` is an empty array. If ``values`` is empty and ``valueQuery`` is `nil`, invalid SQL
    /// is generated.
    public var valueQuery: (any SQLExpression)? = nil

    /// If not `nil`, a strategy for resolving conflicts created by violations of applicable constraints.
    ///
    /// See ``SQLConflictResolutionStrategy``.
    public var conflictStrategy: SQLConflictResolutionStrategy? = nil

    /// An optional ``SQLReturning`` clause specifying data to return from the inserted rows.
    ///
    /// Most often used to return a list of identifiers automatically generated for newly inserted rows.
    public var returning: SQLReturning? = nil
    
    /// Create a new row insertion query.
    ///
    /// - Parameter table: The table to which rows are to be added.
    @inlinable
    public init(table: any SQLExpression) {
        self.table = table
    }
    
    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("INSERT")
            $0.append(self.conflictStrategy?.queryModifier(for: $0))
            $0.append("INTO", self.table)
            $0.append(SQLGroupExpression(self.columns))
            if !self.values.isEmpty {
                $0.append("VALUES", SQLList(self.values.map(SQLGroupExpression.init)))
            } else if let subquery = self.valueQuery {
                $0.append(subquery)
            }
            $0.append(self.conflictStrategy)
            $0.append(self.returning)
        }
    }
}
