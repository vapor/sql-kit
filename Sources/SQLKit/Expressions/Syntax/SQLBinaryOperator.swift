/// SQL binary expression operators, i.e., `==`, `!=`, `AND`, `+`, etc.
public enum SQLBinaryOperator: SQLExpression {
    /// `=` or `==`
    case equal
    
    /// `!=` or `<>`
    case notEqual
    
    /// `>`
    case greaterThan
    
    /// `<`
    case lessThan
    
    /// `>=`
    case greaterThanOrEqual
    
    /// `<=`
    case lessThanOrEqual
    
    /// `LIKE`
    case like
    
    /// `NOT LIKE`
    case notLike
    
    /// `IN`
    case `in`
    
    /// `NOT IN`
    case `notIn`
    
    /// `AND`
    case and
    
    /// `OR`
    case or
    
    /// `||`
    case concatenate
    
    /// `*`
    case multiply
    
    /// `/`
    case divide
    
    /// `%`
    case modulo
    
    /// `+`
    case add
    
    /// `-`
    case subtract

    /// `IS`
    case `is`

    /// `IS NOT`
    case isNot
    
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .equal: serializer.write("=")
        case .notEqual: serializer.write("<>")
        case .and: serializer.write("AND")
        case .or: serializer.write("OR")
        case .in: serializer.write("IN")
        case .notIn: serializer.write("NOT IN")
        case .greaterThan: serializer.write(">")
        case .greaterThanOrEqual: serializer.write(">=")
        case .lessThan: serializer.write("<")
        case .lessThanOrEqual: serializer.write("<=")
        case .is: serializer.write("IS")
        case .isNot: serializer.write("IS NOT")
        case .like: serializer.write("LIKE")
        case .notLike: serializer.write("NOT LIKE")
        case .multiply: serializer.write("*")
        case .divide: serializer.write("/")
        case .modulo: serializer.write("%")
        case .add: serializer.write("+")
        case .subtract: serializer.write("-")

        // See https://dev.mysql.com/doc/refman/8.0/en/sql-mode.html#sqlmode_pipes_as_concat
        case .concatenate:
            fatalError("""
                || is not implemented because MySQL doesn't always support it, even though everyone else does.
                Use `SQLFunction("CONCAT", args...)` for MySQL or `SQLRaw("||")` with Postgres and SQLite.
                """)
        }
    }
}
