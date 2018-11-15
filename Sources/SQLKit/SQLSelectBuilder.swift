/// Builds `SQLSelect` queries.
///
///     conn.select()
///         .all().from(Planet.self)
///         .where(\Planet.name == "Earth")
///         .all(decoding: Planet.self)
///
/// See `SQLQueryFetcher` and `SQLPredicateBuilder` for more information.
public final class SQLSelectBuilder<Database>: SQLQueryFetcher, SQLPredicateBuilder
    where Database: SQLDatabase
{
    /// `Select` query being built.
    public var select: Database.Query.Select
    
    /// See `SQLQueryBuilder`.
    public var database: Database
    
    /// See `SQLQueryBuilder`.
    public var query: Database.Query {
        return .select(select)
    }
    
    /// See `SQLWhereBuilder`.
    public var predicate: Database.Query.Select.Expression? {
        get { return select.predicate }
        set { select.predicate = newValue }
    }
    
    /// Creates a new `SQLCreateTableBuilder`.
    public init(_ select: Database.Query.Select, on database: Database) {
        self.select = select
        self.database = database
    }
    
    /// Adds a column to be returned in the result set.
    ///
    ///     conn.select().column(\User.name)
    ///
    /// - parameters:
    ///     - keyPath: KeyPath to column.
    /// - returns: Self for chaining.
    public func column(_ column: Database.Query.Select.Expression.ColumnIdentifier) -> Self {
        return self.column(.column(column))
    }
    
    /// Adds an expression column to the result set.
    ///
    ///     conn.select()
    ///         .column(.binary(1, .plus, 1), as: "two")
    ///
    /// - parameters:
    ///     - expression: Expression to resolve.
    ///     - alias: Optional alias for the result. This will be the value's
    ///              key in the result set.
    /// - returns: Self for chaining.
    public func column(
        _ expression: Database.Query.Select.Expression,
        as alias: Database.Query.Select.Expression.Identifier
    ) -> Self {
        return column(.alias(expression, as: alias))
    }
    
    /// Adds an expression column to the result set.
    ///
    ///     conn.select()
    ///         .column(.binary(1, .plus, 1))
    ///
    /// - parameters:
    ///     - expression: Expression to resolve.
    /// - returns: Self for chaining.
    public func column(_ expression: Database.Query.Select.Expression) -> Self {
        self.select.columns.append(expression)
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
    public func from(_ table: Database.Query.Select.Identifier) -> Self {
        select.tables.append(table)
        return self
    }
    
//    /// Adds one or more tables to the `FROM` clause.
//    ///
//    ///     conn.select()
//    ///         .all().from("planets")
//    ///         .where(\Planet.name == "Earth")
//    ///         .all(decoding: Planet.self)
//    ///
//    /// - parameters:
//    ///     - tables: One or more table identifiers
//    /// - returns: Self for chaining.
//    public func from(_ tables: Database.Query.Select.TableIdentifier...) -> Self {
//        select.tables += tables
//        return self
//    }
    
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
    public func join(
        _ local: Database.Query.Select.Join.Expression.ColumnIdentifier,
        to table: Database.Query.Select.Join.Identifier,
        _ foreign: Database.Query.Select.Join.Expression.ColumnIdentifier,
        method: Database.Query.Select.Join.Method = .default
    ) -> Self {
        return self.join(
            table: table,
            on: .binary(.column(local), .equal, .column(foreign)),
            method: method
        )
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
    public func join(
        table: Database.Query.Select.Join.Identifier,
        on expression: Database.Query.Select.Join.Expression,
        method: Database.Query.Select.Join.Method = .default
    ) -> Self {
        select.joins.append(.join(method: method, table: table, expression: expression))
        return self
    }
    
    /// Adds a `GROUP BY` clause to the select statement.
    ///
    /// - parameters:
    ///     - expression: `SQLExpression` to group by.
    /// - returns: Self for chaining.
    public func groupBy(_ expression: Database.Query.Select.GroupBy.Expression) -> Self {
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
    /// - parameters:
    ///     - expression: `SQLExpression` to order by.
    ///     - direction: `SQLDirection` to sort the results.
    ///                  Defaults to ascending.
    /// - returns: Self for chaining.
    public func orderBy(_ expression: Database.Query.Select.OrderBy.Expression, _ direction: Database.Query.Select.OrderBy.Direction = .ascending) -> Self {
        select.orderBy.append(.orderBy(expression, direction))
        return self
    }
}

extension SQLSelectBuilder where
    Database.Query.Select.Expression.Subquery == Database.Query.Select
{
    /// Selects a column to the result set from a subquery.
    public func column(
        subquery closure: (SQLSelectBuilder<Database>) -> (SQLSelectBuilder<Database>),
        as alias: Database.Query.Select.Expression.Identifier
    ) -> Self {
        let builder = closure(self.database.select())
        return column(.subquery(builder.select), as: alias)
    }
    
    /// Selects a column to the result set from a subquery.
    public func column(
        subquery closure: (SQLSelectBuilder<Database>) -> (SQLSelectBuilder<Database>)
    ) -> Self {
        let builder = closure(self.database.select())
        return column(.subquery(builder.select))
    }
}

// MARK: Connection

extension SQLDatabase {
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
