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
    /// Specify a column qualified with a table name to be part of the result set of the query.
    ///
    /// This method is deprecated. Use ``SQLColumn/init(_:table:)-7zgbm`` or ``SQLColumn/init(_:table:)-21210`` instead.
    @inlinable
    @discardableResult
    @available(*, deprecated, renamed: "SQLColumn.init(_:table:)", message: "Use ``SQLColumn.init(_:table:)`` instead.")
    public func column(table: some StringProtocol, column: some StringProtocol) -> Self {
        self.column(SQLColumn(.init(column), table: .init(table)))
    }

    /// Specify a column to retrieve with an aliased name.
    @inlinable
    @discardableResult
    public func column(_ column: some StringProtocol, as alias: some StringProtocol) -> Self {
        return self.column(SQLColumn(.init(column)), as: SQLIdentifier(.init(alias)))
    }

    /// Specify a column to retrieve with an aliased name.
    @inlinable
    @discardableResult
    public func column(_ column: some SQLExpression, as alias: some StringProtocol) -> Self {
        self.column(column, as: SQLIdentifier(.init(alias)))
    }

    /// Specify a column to retrieve with an aliased name.
    @inlinable
    @discardableResult
    public func column(_ column: some SQLExpression, as alias: some SQLExpression) -> Self {
        self.column(SQLAlias(column, as: alias))
    }
}
