/// SQL data type protocol, i.e., `INTEGER`, `TEXT`, etc.
public enum SQLDataType: SQLExpression {
    case smallint
    case int
    case bigint
    case text
    case real
    case blob

    @available(*, deprecated, message: "This is a test utility method that was incorrectly made public. Use `.custom()` directly instead.")
    public static func type(_ string: String) -> Self {
        .custom(SQLIdentifier(string))
    }

    case custom(SQLExpression)
    
    public func serialize(to serializer: inout SQLSerializer) {
        let sql: SQLExpression
        if let dialect = serializer.dialect.customDataType(for: self) {
            sql = dialect
        } else {
            switch self {
            case .smallint:
                sql = SQLRaw("SMALLINT")
            case .int:
                sql = SQLRaw("INTEGER")
            case .bigint:
                sql = SQLRaw("BIGINT")
            case .text:
                sql = SQLRaw("TEXT")
            case .real:
                sql = SQLRaw("REAL")
            case .blob:
                sql = SQLRaw("BLOB")
            case .custom(let expression):
                sql = expression
            }
        }
        sql.serialize(to: &serializer)
    }
}
