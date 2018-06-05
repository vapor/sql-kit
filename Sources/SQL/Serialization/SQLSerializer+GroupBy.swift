extension SQLSerializer {
    /// See `SQLSerializer`.
    public func serialize(groupBys: [SQLQuery.DML.GroupBy]) -> String {
        var statement: [String] = []
        
        statement.append("GROUP BY")
        statement.append(groupBys.map({
            switch $0.storage {
            case .column(let column): return serialize(column: column)
            case .computed(let computed): return serialize(column: computed)
            }
        }).joined(separator: ", "))
        
        return statement.joined(separator: " ")
    }
    
}


