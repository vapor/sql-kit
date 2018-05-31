public struct DataQuery {
    public static func select(
        _ keys: DataManipulationQuery.Key...,
        from table: String,
        joins: [DataManipulationQuery.Join] = [],
        where predicates: [DataManipulationQuery.Predicates] = [],
        groupBys: [DataManipulationQuery.GroupBy] = [],
        orderBys: [DataManipulationQuery.OrderBy] = [],
        limit: Int? = nil,
        offset: Int? = nil
    ) -> DataQuery {
        return .dml(statement: .select(), table: table, keys: keys, joins: joins, predicates: predicates, groupBys: groupBys, orderBys: orderBys, limit: limit, offset: offset)
    }
    
    public static func dml(
        statement: DataManipulationQuery.Statement = .select(),
        table: String,
        keys: [DataManipulationQuery.Key] = [],
        columns: [DataManipulationQuery.Column: DataManipulationQuery.Value] = [:],
        joins: [DataManipulationQuery.Join] = [],
        predicates: [DataManipulationQuery.Predicates] = [],
        groupBys: [DataManipulationQuery.GroupBy] = [],
        orderBys: [DataManipulationQuery.OrderBy] = [],
        limit: Int? = nil,
        offset: Int? = nil
    ) -> DataQuery {
        return .init(storage: .dml(.init(statement: statement, table: table, keys: keys, columns: columns, joins: joins, predicates: predicates, groupBys: groupBys, orderBys: orderBys, limit: limit, offset: offset)))
    }
    
    let storage: Storage
    
    enum Storage {
        case dml(DataManipulationQuery)
        case ddl(DataDefinitionQuery)
    }
}
