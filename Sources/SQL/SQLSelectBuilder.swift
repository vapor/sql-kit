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
    
    /// Adds a `JOIN` clause to this select statement.
    ///
    ///     conn.select()
    ///         .all().from(Planet.self)
    ///         .join(\Planet.galaxyID, to: \Galaxy.id)
    ///
    /// Use in conjunction with multiple decode methods from `SQLQueryFetcher` to
    /// fetch joined data.
    ///
    /// - parameters:
    ///     - method: `SQLJoinMethod` to use.
    ///     - local: Local column to join.
    ///     - foreign: Foreign column to join.
    /// - returns: Self for chaining.
    public func join<A, B, C, D>(
        _ method: Connection.Query.Select.Join.Method = .default,
        _ local: KeyPath<A, B>,
        to foreign: KeyPath<C, D>
    ) -> Self where A: SQLTable, B: Encodable, C: SQLTable, D: Encodable {
        return join(method, C.self, on: local == foreign)
    }
    
    public func join<Table>(_ table: Table.Type, on expression: Connection.Query.Select.Join.Expression) -> Self
        where Table: SQLTable
    {
        return join(.default, table, on: expression)
    }
    
    public func join<Table>(_ method: Connection.Query.Select.Join.Method, _ table: Table.Type, on expression: Connection.Query.Select.Join.Expression) -> Self
        where Table: SQLTable
    {
        select.joins.append(.join(method, .table(Table.self), expression))
        return self
    }
    
    public func groupBy<T,V>(_ keyPath: KeyPath<T, V>) -> Self
        where T: SQLTable
    {
        return groupBy(.column(.keyPath(keyPath)))
    }
    
    public func groupBy(_ expression: Connection.Query.Select.GroupBy.Expression) -> Self {
        select.groupBy.append(.groupBy(expression))
        return self
    }
    
    public func orderBy<T,V>(_ keyPath: KeyPath<T, V>, _ direction: Connection.Query.Select.OrderBy.Direction = .ascending) -> Self
        where T: SQLTable
    {
        return orderBy(.column(.keyPath(keyPath)), direction)
    }
    
    public func orderBy(_ expression: Connection.Query.Select.OrderBy.Expression, _ direction: Connection.Query.Select.OrderBy.Direction = .ascending) -> Self {
        select.orderBy.append(.orderBy(expression, direction))
        return self
    }
}

// MARK: Connection

extension SQLConnection {
    public func select() -> SQLSelectBuilder<Self> {
        return .init(.select(), on: self)
    }
}
