public final class SQLSelectBuilder<Connection>: SQLQueryFetcher, SQLPredicateBuilder
    where Connection: DatabaseQueryable, Connection.Query: SQLQuery
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
    
    public func column(
        _ expression: Connection.Query.Select.SelectExpression.Expression,
        as alias: Connection.Query.Select.SelectExpression.Identifier? = nil
    ) -> Self {
        return column(.expression(expression, alias: alias))
    }
    
    public func all() -> Self {
        return column(.all)
    }
    
    public func all(table: String) -> Self {
        return column(.allTable(table))
    }
    
    public func column(_ column: Connection.Query.Select.SelectExpression) -> Self {
        select.columns.append(column)
        return self
    }
    
    public func from(_ tables: Connection.Query.Select.TableIdentifier...) -> Self {
        select.tables += tables
        return self
    }
    
    public func from<Table>(_ table: Table.Type) -> Self
        where Table: SQLTable
    {
        select.tables.append(.table(.identifier(Table.sqlTableIdentifierString)))
        return self
    }
    
    public func join<A, B, C, D>(
        _ local: KeyPath<A, B>,
        to foreign: KeyPath<C, D>
    ) -> Self where A: SQLTable, B: Encodable, C: SQLTable, D: Encodable {
        return join(.default, local, to: foreign)
    }
    
    public func join<A, B, C, D>(
        _ method: Connection.Query.Select.Join.Method,
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

// MARK: Columns

extension SQLSelectBuilder {
    public func column<T, V>(
        _ keyPath: KeyPath<T, V>,
        as alias: Connection.Query.Select.SelectExpression.Identifier? = nil
    ) -> Self where T: SQLTable {
        return self.column(.expression(.column(.keyPath(keyPath)), alias: alias))
    }
    
    public func columns<T1, V1, T2, V2>(
        _ keyPath1: KeyPath<T1, V1>, as alias1: Connection.Query.Select.SelectExpression.Identifier? = nil,
        _ keyPath2: KeyPath<T2, V2>, as alias2: Connection.Query.Select.SelectExpression.Identifier? = nil
    ) -> Self where T1: SQLTable, T2: SQLTable {
        return self
            .column(.expression(.column(.keyPath(keyPath1)), alias: alias1))
            .column(.expression(.column(.keyPath(keyPath2)), alias: alias2))
    }
    
    public func columns<T1, V1, T2, V2, T3, V3>(
        _ keyPath1: KeyPath<T1, V1>, as alias1: Connection.Query.Select.SelectExpression.Identifier? = nil,
        _ keyPath2: KeyPath<T2, V2>, as alias2: Connection.Query.Select.SelectExpression.Identifier? = nil,
        _ keyPath3: KeyPath<T3, V3>, as alias3: Connection.Query.Select.SelectExpression.Identifier? = nil
    ) -> Self where T1: SQLTable, T2: SQLTable, T3: SQLTable {
        return self
            .column(.expression(.column(.keyPath(keyPath1)), alias: alias1))
            .column(.expression(.column(.keyPath(keyPath2)), alias: alias2))
            .column(.expression(.column(.keyPath(keyPath3)), alias: alias3))
    }
    
    public func columns<T1, V1, T2, V2, T3, V3, T4, V4>(
        _ keyPath1: KeyPath<T1, V1>, as alias1: Connection.Query.Select.SelectExpression.Identifier? = nil,
        _ keyPath2: KeyPath<T2, V2>, as alias2: Connection.Query.Select.SelectExpression.Identifier? = nil,
        _ keyPath3: KeyPath<T3, V3>, as alias3: Connection.Query.Select.SelectExpression.Identifier? = nil,
        _ keyPath4: KeyPath<T4, V4>, as alias4: Connection.Query.Select.SelectExpression.Identifier? = nil
    ) -> Self where T1: SQLTable, T2: SQLTable, T3: SQLTable, T4: SQLTable {
        return self
            .column(.expression(.column(.keyPath(keyPath1)), alias: alias1))
            .column(.expression(.column(.keyPath(keyPath2)), alias: alias2))
            .column(.expression(.column(.keyPath(keyPath3)), alias: alias3))
            .column(.expression(.column(.keyPath(keyPath4)), alias: alias4))
    }
    
    public func columns<T1, V1, T2, V2, T3, V3, T4, V4, T5, V5>(
        _ keyPath1: KeyPath<T1, V1>, as alias1: Connection.Query.Select.SelectExpression.Identifier? = nil,
        _ keyPath2: KeyPath<T2, V2>, as alias2: Connection.Query.Select.SelectExpression.Identifier? = nil,
        _ keyPath3: KeyPath<T3, V3>, as alias3: Connection.Query.Select.SelectExpression.Identifier? = nil,
        _ keyPath4: KeyPath<T4, V4>, as alias4: Connection.Query.Select.SelectExpression.Identifier? = nil,
        _ keyPath5: KeyPath<T5, V5>, as alias5: Connection.Query.Select.SelectExpression.Identifier? = nil
    ) -> Self where T1: SQLTable, T2: SQLTable, T3: SQLTable, T4: SQLTable, T5: SQLTable {
        return self
            .column(.expression(.column(.keyPath(keyPath1)), alias: alias1))
            .column(.expression(.column(.keyPath(keyPath2)), alias: alias2))
            .column(.expression(.column(.keyPath(keyPath3)), alias: alias3))
            .column(.expression(.column(.keyPath(keyPath4)), alias: alias4))
            .column(.expression(.column(.keyPath(keyPath5)), alias: alias5))
    }
    
    public func columns<T1, V1, T2, V2, T3, V3, T4, V4, T5, V5, T6, V6>(
        _ keyPath1: KeyPath<T1, V1>, as alias1: Connection.Query.Select.SelectExpression.Identifier? = nil,
        _ keyPath2: KeyPath<T2, V2>, as alias2: Connection.Query.Select.SelectExpression.Identifier? = nil,
        _ keyPath3: KeyPath<T3, V3>, as alias3: Connection.Query.Select.SelectExpression.Identifier? = nil,
        _ keyPath4: KeyPath<T4, V4>, as alias4: Connection.Query.Select.SelectExpression.Identifier? = nil,
        _ keyPath5: KeyPath<T5, V5>, as alias5: Connection.Query.Select.SelectExpression.Identifier? = nil,
        _ keyPath6: KeyPath<T6, V6>, as alias6: Connection.Query.Select.SelectExpression.Identifier? = nil
    ) -> Self where T1: SQLTable, T2: SQLTable, T3: SQLTable, T4: SQLTable, T5: SQLTable, T6: SQLTable {
        return self
            .column(.expression(.column(.keyPath(keyPath1)), alias: alias1))
            .column(.expression(.column(.keyPath(keyPath2)), alias: alias2))
            .column(.expression(.column(.keyPath(keyPath3)), alias: alias3))
            .column(.expression(.column(.keyPath(keyPath4)), alias: alias4))
            .column(.expression(.column(.keyPath(keyPath5)), alias: alias5))
            .column(.expression(.column(.keyPath(keyPath6)), alias: alias6))
    }
}

// MARK: Connection

extension DatabaseQueryable where Query: SQLQuery {
    public func select() -> SQLSelectBuilder<Self> {
        return .init(.select(), on: self)
    }
}
