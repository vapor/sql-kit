extension SQLSerializer {
    /// See `SQLSerializer`.
    public func serialize(groupBys: [DataGroupBy]) -> String {
        var statement: [String] = []
        
        statement.append("GROUP BY")
        statement.append(groupBys.map({
            switch $0 {
            case .column(let column): return serialize(column: column)
            case .computed(let computed): return serialize(column: computed)
            }
        }).joined(separator: ", "))
        
        return statement.joined(separator: " ")
    }
    
}


