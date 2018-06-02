public struct SQLQuery {
    /// MARK: DML
    
    /// Creates a `SELECT` query.
    ///
    ///     let query: Query = .select([.all], from: "users")
    ///
    /// - parameters:
    ///     - keys: One or more keys to select.
    ///     - table: Table to select rows from.
    ///     - joins: Zero or more tables to join.
    ///     - predicates: Predicates to filter the result set.
    ///     - groupBys: Zero or more group bys to group result keys.
    ///     - orderBys: Zero or more order bys to sort the result set.
    ///     - limit: Optional result set limit.
    ///     - offset: Optional result set offset.
    /// - returns: Newly created `Query`.
    public static func select(
        _ keys: [DML.Key],
        from table: String,
        joins: [DML.Join] = [],
        where predicates: [DML.Predicate] = [],
        groupBys: [DML.GroupBy] = [],
        orderBys: [DML.OrderBy] = [],
        limit: Int? = nil,
        offset: Int? = nil
    ) -> SQLQuery {
        return .dml(statement: .select, table: table, keys: keys, joins: joins, predicates: predicates, groupBys: groupBys, orderBys: orderBys, limit: limit, offset: offset)
    }
    
    
    /// Creates a `SELECT` query.
    ///
    ///     let query: Query = .dml(statement: .select, table: "users", keys: [.all])
    ///
    /// - parameters:
    ///     - statement: SQL manipulation statement to use.
    ///     - table: Table to select rows from.
    ///     - keys: One or more keys to select.
    ///     - columns: Dictionary of column / value paired data to supply.
    ///     - joins: Zero or more tables to join.
    ///     - predicates: Predicates to filter the result set.
    ///     - groupBys: Zero or more group bys to group result keys.
    ///     - orderBys: Zero or more order bys to sort the result set.
    ///     - limit: Optional result set limit.
    ///     - offset: Optional result set offset.
    /// - returns: Newly created `Query`.
    public static func dml(
        statement: DML.Statement = .select,
        table: String,
        keys: [DML.Key] = [],
        columns: [DML.Column: DML.Value] = [:],
        joins: [DML.Join] = [],
        predicates: [DML.Predicate] = [],
        groupBys: [DML.GroupBy] = [],
        orderBys: [DML.OrderBy] = [],
        limit: Int? = nil,
        offset: Int? = nil
    ) -> SQLQuery {
        return .init(.dml(.init(statement: statement, table: table, keys: keys, columns: columns, joins: joins, predicates: predicates, groupBys: groupBys, orderBys: orderBys, limit: limit, offset: offset)))
    }
    
    // MARK: DDL
    
    public static func create(
        ifNotExists: Bool = false,
        table: String,
        columns: [DDL.ColumnDefinition],
        constraints: [DDL.Constraint] = []
    ) -> SQLQuery {
        return ddl(statement: .create(ifNotExists: ifNotExists), table: table, createColumns: columns, createConstraints: constraints)
    }
    
    public static func drop(
        ifExists: Bool = false,
        table: String
    ) -> SQLQuery {
        return ddl(statement: .drop(ifExists: ifExists), table: table)
    }
    
    public static func ddl(
        statement: DDL.Statement = .create,
        table: String,
        createColumns: [DDL.ColumnDefinition] = [],
        deleteColumns: [DML.Column] = [],
        createConstraints: [DDL.Constraint] = [],
        deleteConstraints: [DDL.Constraint] = []
    ) -> SQLQuery {
        return self.init(.ddl(.init(statement: statement, table: table, createColumns: createColumns, deleteColumns: deleteColumns, createConstraints: createConstraints, deleteConstraints: deleteConstraints)))
    }
    
    /// Internal storage type.
    /// - warning: Enum cases are subject to change.
    public enum Storage {
        /// DML
        case dml(DML)
        /// DDL
        case ddl(DDL)
    }
    
    /// Internal storage.
    /// - warning: Enum cases are subject to change.
    public let storage: Storage
    
    /// Creates a new `Query` from internal storage.
    /// - warning: Enum cases are subject to change.
    public init(_ storage: Storage) {
        self.storage = storage
    }
}
