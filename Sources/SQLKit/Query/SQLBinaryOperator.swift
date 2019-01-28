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
    
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .equal: serializer.write("=")
        case .notEqual: serializer.write("!=")
        case .and: serializer.write("AND")
        case .or: serializer.write("OR")
        case .in: serializer.write("IN")
        case .notIn: serializer.write("NOT IN")
        default:
            print(self)
            fatalError()
        }
    }
}
