/// Literal expression value, i.e., `DEFAULT`, `FALSE`, `42`, etc.
public enum SQLLiteral: SQLExpression {
    /// *
    case all
    
    /// Creates a new ``SQLLiteral`` from a string.
    case string(String)
    
    /// Creates a new ``SQLLiteral`` from a numeric string (no quotes).
    case numeric(String)
    
    /// Creates a new null ``SQLLiteral``, i.e., `NULL`.
    case null
    
    /// Creates a new default ``SQLLiteral`` literal, i.e., `DEFAULT` or sometimes `NULL`.
    case `default`
    
    /// Creates a new boolean ``SQLLiteral``, i.e., `FALSE` or sometimes `0`.
    case boolean(Bool)
    
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
