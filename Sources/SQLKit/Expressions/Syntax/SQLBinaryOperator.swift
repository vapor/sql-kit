/// SQL binary expression operators.
public enum SQLBinaryOperator: SQLExpression {
    /// Equality. `=` or `==` in most dialects.
    case equal
    
    /// Inequality. `!=` or `<>` in most dialects.
    case notEqual
    
    /// Arranged in descending order, or `>`.
    case greaterThan
    
    /// Arranged in ascending order, or `<`.
    case lessThan
    
    /// Not arranged in ascending order, or `>=`.
    case greaterThanOrEqual
    
    /// Not arranged in descending order, or `<=`.
    case lessThanOrEqual
    
    /// SQL pattern match, or `LIKE`.
    case like
    
    /// SQL pattern mismatch, or `NOT LIKE`.
    case notLike
    
    /// Set membership, or `IN`.
    case `in`
    
    /// Set exclusion, or `NOT IN`.
    case `notIn`
    
    /// Logical conjunction, or `AND`.
    case and
    
    /// Logical disjunction, or `OR`.
    case or
    
    /// Arithmetic multiplication, or `*`.
    case multiply
    
    /// Arithmetic division, or `/`.
    case divide
    
    /// Arithmetic remainder, or `%`.
    case modulo
    
    /// Arithmetic addition, or `+`.
    case add
    
    /// Arithmetic subtraction, or `-`.
    case subtract

    /// Typed identity, or `IS`.
    case `is`

    /// Typed dissimilarity, or `IS NOT`.
    case isNot
    
    /// String concatenation, or `||`.
    ///
    /// This operator is not implemented. Attempting to use it will trigger a runtime error.
    @available(*, deprecated, message: "The || concatenation operator is not implemented due to legacy compatibility issues. Use SQLFunction(\"concat\") instead.")
    case concatenate
    
    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .equal:              serializer.write("=")
        case .notEqual:           serializer.write("<>")
        case .and:                serializer.write("AND")
        case .or:                 serializer.write("OR")
        case .in:                 serializer.write("IN")
        case .notIn:              serializer.write("NOT IN")
        case .greaterThan:        serializer.write(">")
        case .greaterThanOrEqual: serializer.write(">=")
        case .lessThan:           serializer.write("<")
        case .lessThanOrEqual:    serializer.write("<=")
        case .is:                 serializer.write("IS")
        case .isNot:              serializer.write("IS NOT")
        case .like:               serializer.write("LIKE")
        case .notLike:            serializer.write("NOT LIKE")
        case .multiply:           serializer.write("*")
        case .divide:             serializer.write("/")
        case .modulo:             serializer.write("%")
        case .add:                serializer.write("+")
        case .subtract:           serializer.write("-")

        // See https://dev.mysql.com/doc/refman/8.0/en/sql-mode.html#sqlmode_pipes_as_concat
        case .concatenate:
            serializer.database.logger.warning("|| is not implemented, because it doesn't always work. Use `SQLFunction(\"CONCAT\", args...)` for MySQL or `SQLRaw(\"||\")` for Postgres and SQLite.")
        }
    }
}
