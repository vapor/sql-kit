/// SQL data type protocol, i.e., `INTEGER`, `TEXT`, etc.
public enum SQLDataType: SQLExpression {
    case smallint
    case int
    case bigint
    case text
    case real
    case blob
    case custom(any SQLExpression)

    @available(*, deprecated, message: "This is a test utility method that was incorrectly made public. Use `.custom()` directly instead.")
    @inlinable
    public static func type(_ string: String) -> Self {
        .custom(SQLIdentifier(string))
    }
    
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        let sql: any SQLExpression
        if let dialect = serializer.dialect.customDataType(for: self) {
            sql = dialect
        } else {
            switch self {
            case .smallint:        sql = SQLRaw("SMALLINT")
            case .int:             sql = SQLRaw("INTEGER")
            case .bigint:          sql = SQLRaw("BIGINT")
            case .text:            sql = SQLRaw("TEXT")
            case .real:            sql = SQLRaw("REAL")
            case .blob:            sql = SQLRaw("BLOB")
            case .custom(let exp): sql = exp
            }
        }
        sql.serialize(to: &serializer)
    }
}
