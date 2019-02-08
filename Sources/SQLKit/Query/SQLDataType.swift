/// SQL data type protocol, i.e., `INTEGER`, `TEXT`, etc.
public enum SQLDataType: SQLExpression {
    case smallint
    case int
    case bigint
    case text
    case real
    case blob
    
    public func serialize(to serializer: inout SQLSerializer) {
        let sql: String
        switch self {
        case .smallint: sql = "SMALLINT"
        case .int: sql = "INT"
        case .bigint: sql = "BIGINT"
        case .text: sql = "TEXT"
        case .real: sql = "REAL"
        case .blob: sql = "BLOB"
        }
        serializer.write(sql)
    }
}
