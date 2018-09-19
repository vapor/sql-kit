/// Builds `SQLSelect` queries.
///
///     conn.select()
///         .all().from(Planet.self)
///         .where(\Planet.name == "Earth")
///         .all(decoding: Planet.self)
///
/// See `SQLQueryFetcher` and `SQLPredicateBuilder` for more information.
public final class SQLSelectBuilder<Connection>: SQLQueryFetcher, SQLPredicateBuilder
    where Connection: SQLConnection
{
    /// `Select` query being built.
    public var select: Connection.Query.Select
    
    /// See `SQLQueryBuilder`.
    public var connection: Connection
    
    /// See `SQLQueryBuilder`.
    public var query: Connection.Query {
        return .select(select)
    }
    
    /// See `SQLWhereBuilder`.
    public var predicate: Connection.Query.Select.Expression? {
        get { return select.predicate }
        set { select.predicate = newValue }
    }
    
    /// Creates a new `SQLCreateTableBuilder`.
    public init(_ select: Connection.Query.Select, on connection: Connection) {
        self.select = select
        self.connection = connection
    }
    
    /// Adds a column to be returned in the result set.
    ///
    ///     conn.select().column("name")
    ///
    /// Table identifiers can also be specified.
    ///
    ///     conn.select().column("name", table: "users")
    ///
    /// - parameters:
    ///     - name: Column identifier.
    ///     - table: Optional table identifier.
    /// - returns: Self for chaining.
    public func column(
        _ name: Connection.Query.Select.SelectExpression.Expression.ColumnIdentifier.Identifier,
        table: Connection.Query.Select.SelectExpression.Expression.ColumnIdentifier.TableIdentifier? = nil
    ) -> Self {
        return column(expression: .column(.column(table, name)))
    }
    
    /// Adds a column to be returned in the result set.
    ///
    ///     conn.select().column(\User.name)
    ///
    /// - parameters:
    ///     - keyPath: KeyPath to column.
    /// - returns: Self for chaining.
    public func column<T, V>(_ keyPath: KeyPath<T, V>) -> Self
        where T: SQLTable
    {
        return column(expression: .column(.keyPath(keyPath)))
    }
    
    /// Adds a function expression column to the result set.
    ///
    ///     conn.select()
    ///         .column(function: "count", .all, as: "count")
    ///
    /// - parameters:
    ///     - function: Name of the function to execute.
    ///     - arguments: Zero or more arguments to pass to the function.
    ///                  See `SQLArgument`.
    ///     - alias: Optional alias for the result. This will be the value's
    ///              key in the result set.
    /// - returns: Self for chaining.
    public func column(
        function: String,
        _ arguments: Connection.Query.Select.SelectExpression.Expression.Function.Argument...,
        as alias: Connection.Query.Select.SelectExpression.Identifier? = nil
    ) -> Self {
        return column(expression: .function(.function(function, arguments)), as: alias)
    }
    
    /// Adds an expression column to the result set.
    ///
    ///     conn.select()
    ///         .column(expression: .binary(1, .plus, 1), as: "two")
    ///
    /// - parameters:
    ///     - expression: Expression to resolve.
    ///     - alias: Optional alias for the result. This will be the value's
    ///              key in the result set.
    /// - returns: Self for chaining.
    public func column(
        expression: Connection.Query.Select.SelectExpression.Expression,
        as alias: Connection.Query.Select.SelectExpression.Identifier? = nil
    ) -> Self {
        return column(.expression(expression, alias: alias))
    }
    
    /// All columns, i.e., `*`.
    ///
    ///     conn.select()
    ///         .all().from(Planet.self)
    ///         .where(\Planet.name == "Earth")
    ///         .all(decoding: Planet.self)
    ///
    /// - returns: Self for chaining.
    public func all() -> Self {
        return column(.all)
    }
    
    /// All columns from a specified table, i.e., `table.*`.
    ///
    ///     conn.select()
    ///         .all(table: Planet.self).from(Planet.self)
    ///         .where(\Planet.name == "Earth")
    ///         .all(decoding: Planet.self)
    ///
    /// - parameters:
    ///     - table: SQLTable to select all columns from.
    /// - returns: Self for chaining.
    public func all<T>(table: T.Type) -> Self
        where T: SQLTable
    {
        return column(.allTable(.table(T.self)))
    }
    
    /// Adds a `SQLSelectExpression` to the result set.
    public func column(_ column: Connection.Query.Select.SelectExpression) -> Self {
        select.columns.append(column)
        return self
    }
    
    /// Adds a table to the `FROM` clause.
    ///
    ///     conn.select()
    ///         .all().from(Planet.self)
    ///         .where(\Planet.name == "Earth")
    ///         .all(decoding: Planet.self)
    ///
    /// - parameters:
    ///     - table: `SQLTable` type to select from.
    /// - returns: Self for chaining.
    public func from<Table>(_ table: Table.Type) -> Self
        where Table: SQLTable
    {
        select.tables.append(.table(.identifier(Table.sqlTableIdentifierString)))
        return self
    }
    
    /// Adds one or more tables to the `FROM` clause.
    ///
    ///     conn.select()
    ///         .all().from("planets")
    ///         .where(\Planet.name == "Earth")
    ///         .all(decoding: Planet.self)
    ///
    /// - parameters:
    ///     - tables: One or more table identifiers
    /// - returns: Self for chaining.
    public func from(_ tables: Connection.Query.Select.TableIdentifier...) -> Self {
        select.tables += tables
        return self
    }
    
    /// Adds a `JOIN` clause to the select statement.
    ///
    ///     conn.select()
    ///         .all().from(Planet.self)
    ///         .join(\Planet.galaxyID, to: \Galaxy.id)
    ///
    /// Use in conjunction with multiple decode methods from `SQLQueryFetcher` to
    /// fetch joined data.
    ///
    /// - parameters:
    ///     - local: Local column to join.
    ///     - foreign: Foreign column to join.
    ///     - method: `SQLJoinMethod` to use.
    /// - returns: Self for chaining.
    public func join<A, B, C, D>(
        _ local: KeyPath<A, B>,
        to foreign: KeyPath<C, D>,
        method: Connection.Query.Select.Join.Method = .default
    ) -> Self where A: SQLTable, B: Encodable, C: SQLTable, D: Encodable {
        return join(C.self, on: local == foreign, method: method)
    }
    
    /// Adds a `JOIN` clause to the select statement.
    ///
    ///     conn.select()
    ///         .all().from(Planet.self)
    ///         .join(Galaxy.self, on: \Planet.galaxyID == \Galaxy.id)
    ///
    /// Use in conjunction with multiple decode methods from `SQLQueryFetcher` to
    /// fetch joined data.
    ///
    /// - parameters:
    ///     - table: Foreign `SQLTable` to join.
    ///     - expression: `SQLExpression` to use for joining the tables.
    ///     - method: `SQLJoinMethod` to use.
    /// - returns: Self for chaining.
    public func join<Table>(
        _ table: Table.Type,
        on expression: Connection.Query.Select.Join.Expression,
        method: Connection.Query.Select.Join.Method = .default
    ) -> Self
        where Table: SQLTable
    {
        select.joins.append(.join(method, .table(Table.self), expression))
        return self
    }
    
    /// Adds a `GROUP BY` clause to the select statement.
    ///
    ///     conn.select()
    ///         .all().from(Planet.self)
    ///         .groupBy(\Planet.name)
    ///
    /// - parameters:
    ///     - keyPath: Key path to group by.
    /// - returns: Self for chaining.
    public func groupBy<T,V>(_ keyPath: KeyPath<T, V>) -> Self
        where T: SQLTable
    {
        return groupBy(.column(.keyPath(keyPath)))
    }
    
    /// Adds a `GROUP BY` clause to the select statement.
    ///
    /// - parameters:
    ///     - expression: `SQLExpression` to group by.
    /// - returns: Self for chaining.
    public func groupBy(_ expression: Connection.Query.Select.GroupBy.Expression) -> Self {
        select.groupBy.append(.groupBy(expression))
        return self
    }
    
    /// Adds a `LIMIT` clause to the select statement.
    ///
    ///     builder.limit(5)
    ///
    /// - parameters:
    ///     - max: Optional maximum limit.
    ///            If `nil`, existing limit will be removed.
    /// - returns: Self for chaining.
    public func limit(_ max: Int?) -> Self {
        self.select.limit = max
        return self
    }
    
    /// Adds a `OFFSET` clause to the select statement.
    ///
    ///     builder.offset(5)
    ///
    /// - parameters:
    ///     - max: Optional offset.
    ///            If `nil`, existing offset will be removed.
    /// - returns: Self for chaining.
    public func offset(_ n: Int?) -> Self {
        self.select.offset = n
        return self
    }
    
    /// Adds an `ORDER BY` clause to the select statement.
    ///
    ///     conn.select()
    ///         .all().from(Planet.self)
    ///         .orderBy(\Planet.name, .ascending)
    ///
    /// - parameters:
    ///     - keyPath: Key path to order by.
    ///     - direction: `SQLDirection` to sort the results.
    ///                  Defaults to ascending.
    /// - returns: Self for chaining.
    public func orderBy<T,V>(
        _ keyPath: KeyPath<T, V>,
        _ direction: Connection.Query.Select.OrderBy.Direction = .ascending
    ) -> Self
        where T: SQLTable
    {
        return orderBy(.column(.keyPath(keyPath)), direction)
    }
    
    /// Adds an `ORDER BY` clause to the select statement.
    ///
    /// - parameters:
    ///     - expression: `SQLExpression` to order by.
    ///     - direction: `SQLDirection` to sort the results.
    ///                  Defaults to ascending.
    /// - returns: Self for chaining.
    public func orderBy(_ expression: Connection.Query.Select.OrderBy.Expression, _ direction: Connection.Query.Select.OrderBy.Direction = .ascending) -> Self {
        select.orderBy.append(.orderBy(expression, direction))
        return self
    }
}

// MARK: Connection

extension SQLConnection {
    /// Creates a new `SQLSelectBuilder`.
    ///
    ///     conn.select()
    ///         .all().from(Planet.self)
    ///         .where(\Planet.name == "Earth")
    ///         .all(decoding: Planet.self)
    ///
    public func select() -> SQLSelectBuilder<Self> {
        return .init(.select(), on: self)
    }
}
