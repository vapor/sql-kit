/// Common definitions for query builders which permit or require specifying a list of _unqualified_ column names.
///
/// Unqualified column lists are typically used in areas of SQL syntax where only columns belonging to the "current"
/// table (in context) make sense, such as the initial column list of an `INSERT` query, the list of indexed columns
/// for a `CREATE INDEX` query, or the set of columns for the `UPDATE OF` clause of a `CREATE TRIGGER` query.
///
/// For specifying aliasable columns - such as in a `SELECT` query - see ``SQLAliasedColumnListBuilder``.
public protocol SQLUnqualifiedColumnListBuilder: AnyObject {
    var columnList: [any SQLExpression] { get set }
}

extension SQLUnqualifiedColumnListBuilder {
    /// Specify a single column to be included in the list of columns for the query.
    @inlinable
    @discardableResult
    public func column(_ column: String) -> Self {
        self.column(SQLColumn(column))
    }
    
    /// Specify a single column to be included in the list of columns for the query.
    @inlinable
    @discardableResult
    public func column(_ column: any SQLExpression) -> Self {
        self.columnList.append(column)
        return self
    }
    
    /// Specify mutiple columns to be included in the list of columns for the query.
    @inlinable
    @discardableResult
    public func columns(_ columns: String...) -> Self {
        self.columns(columns)
    }

    /// Specify mutiple columns to be included in the list of columns for the query.
    @inlinable
    @discardableResult
    public func columns(_ columns: [String]) -> Self {
        self.columns(columns.map { SQLColumn($0) })
    }

    /// Specify mutiple columns to be included in the list of columns for the query.
    @inlinable
    @discardableResult
    public func columns(_ columns: any SQLExpression...) -> Self {
        self.columns(columns)
    }

    /// Specify mutiple columns to be included in the list of columns for the query.
    @inlinable
    @discardableResult
    public func columns(_ columns: [any SQLExpression]) -> Self {
        self.columnList.append(contentsOf: columns)
        return self
    }
}
