/// Literal expression value, i.e., `DEFAULT`, `FALSE`, `42`, etc.
public enum SQLLiteral: SQLExpression {
    /// `*`
    case all
    
    /// An ``SQLLiteral`` representing the current dialect's equivalent of the `DEFAULT` keyword.
    case `default`
    
    /// An ``SQLLiteral`` representing an SQL `NULL`  in the current dialect.
    case null
    
    /// An ``SQLLiteral`` representing a boolean literal in the current dialect.
    case boolean(Bool)
    
    /// An ``SQLLiteral`` representing a numeric literal in the current dialect.
    case numeric(String)
    
    /// An ``SQLLiteral`` representing a literal string in the current dialect.
    case string(String)
    
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .all:
            serializer.write("*")
            
        case .string(let string):
            serializer.dialect.literalStringQuote.serialize(to: &serializer)
            serializer.write(string)
            serializer.dialect.literalStringQuote.serialize(to: &serializer)
        
        case .numeric(let numeric):
            serializer.write(numeric)
        
        case .null:
            serializer.write("NULL")
        
        case .default:
            serializer.dialect.literalDefault.serialize(to: &serializer)
        
        case .boolean(let bool):
            serializer.dialect.literalBoolean(bool).serialize(to: &serializer)
        }
    }
}
