/// Common definitions for query builders which permit specifying aliased column names.
///
/// Aliasable column lists are typically used in areas of SQL syntax where columns belonging to arbitrary
/// database objects may be specified, such as the list of result columns in a `SELECT` or `VALUES` query.
///
/// An aliased column list builder is also an unqualified column list builder.
/// See ``SQLUnqualifiedColumnListBuilder``.
public protocol SQLAliasedColumnListBuilder: SQLUnqualifiedColumnListBuilder {
    var columns: [any SQLExpression] { get set }
}

extension SQLAliasedColumnListBuilder {
    /// Specify a column to retrieve with an aliased name.
    @inlinable
    @discardableResult
    public func column(_ column: String, as alias: String) -> Self {
        return self.column(SQLColumn(column), as: SQLIdentifier(alias))
    }

    /// Specify a column to retrieve with an aliased name.
    @inlinable
    @discardableResult
    public func column(_ column: any SQLExpression, as alias: String) -> Self {
        self.column(column, as: SQLIdentifier(alias))
    }

    /// Specify a column to retrieve with an aliased name.
    @inlinable
    @discardableResult
    public func column(_ column: any SQLExpression, as alias: any SQLExpression) -> Self {
        self.column(SQLAlias(column, as: alias))
    }
}
